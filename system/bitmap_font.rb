require 'sdl3'

class BitmapFont
  class DstRect
    attr_accessor :src, :dst

    def initialize
      @src = nil
      @dst = SDL::FRect.new
    end
  end

  def initialize(dst_count = 1024)
    @texture = nil
    @width = 0
    @height = 0
    @newline_height = 0
    @space_width = 0
    @src_rects = Array.new(16 * 16) { SDL::FRect.new }
    @dst_rects = Array.new(dst_count) { DstRect.new }
    @dst_count = 0
  end

  def setup(renderer, bmp_fontsheet, char_rgb, background_rgb)
    case bmp_fontsheet
    when String
      bmp_fontsheet_io = SDL::IOFromFile(bmp_fontsheet, 'rb')
      result = setup_io(renderer, bmp_fontsheet_io, char_rgb, background_rgb)
      SDL::CloseIO(bmp_fontsheet_io)
      result
    when FFI::Pointer # assumes bmp_fontsheet is a pointer to SDL::RWops
      setup_io(renderer, bmp_fontsheet, char_rgb, background_rgb)
    else
      raise ArgumentError
    end
  end

  def setup_io(renderer, bmp_fontsheet_io, char_rgb, background_rgb)
    # Create texture from BMP surface
    surface = SDL.LoadBMP_IO(bmp_fontsheet_io, false)
    return false if surface.nil?

    converted_surface = SDL.ConvertSurface(surface, SDL::PIXELFORMAT_RGBA8888)
    if converted_surface.nil?
      # Failed to convert into appropreate format
      SDL.DestroySurface(surface)
      return false
    end

    converted_surface = SDL::Surface.new(converted_surface)
    texture = SDL.CreateTexture(renderer, SDL::PIXELFORMAT_RGBA8888, SDL::TEXTUREACCESS_STREAMING, converted_surface[:w], converted_surface[:h])
    if texture.nil?
      # Failed to craete texture from surface
      SDL.DestroySurface(converted_surface)
      SDL.DestroySurface(surface)
      return false
    end

    @width = converted_surface[:w]
    @height = converted_surface[:h]

    SDL.SetTextureBlendMode(texture, SDL::BLENDMODE_BLEND)

    # Copy font image into texture pixels
    texture_pixels = FFI::MemoryPointer.new(:pointer, 1)
    texture_pitch = FFI::MemoryPointer.new(:int32, 1)
    SDL.LockTexture(texture, nil, texture_pixels, texture_pitch)

    pixels_dst = texture_pixels.read_pointer

    pixels_src = converted_surface[:pixels].read_string_length(converted_surface[:pitch] * converted_surface[:h])
    pixels_dst.write_bytes(pixels_src, 0, pixels_src.length)

    # Make background transparent
    foreground_color = SDL.MapRGB(SDL.GetPixelFormatDetails(converted_surface[:format]), nil, char_rgb[:r], char_rgb[:g], char_rgb[:b])
    background_color = SDL.MapRGB(SDL.GetPixelFormatDetails(converted_surface[:format]), nil, background_rgb[:r], background_rgb[:g], background_rgb[:b])
    transparent_color = SDL.MapRGBA(SDL.GetPixelFormatDetails(converted_surface[:format]), nil, 0x00, 0x00, 0x00, 0x00)

    pixel_count = (texture_pitch.read_int / 4) * @height
    pixel_count.times do |i|
      offset = FFI::NativeType::UINT32.size * i
      pixel_color = pixels_dst.get(:uint32, offset)
      pixels_dst.put(:uint32, offset, pixel_color == background_color ? transparent_color : foreground_color)
    end

    SDL.UnlockTexture(texture)
    SDL.DestroySurface(converted_surface)
    SDL.DestroySurface(surface)

    @texture = texture

    # Build array of SDL_Rect
    rect_width = @width / 16
    rect_height = @height / 8
    @newline_height = 16
    @space_width = 16

    char_code = 0
    16.times do |r|
      16.times do |c|
        @src_rects[char_code][:x] = rect_width * c
        @src_rects[char_code][:y] = rect_height * r
        @src_rects[char_code][:w] = rect_width
        @src_rects[char_code][:h] = rect_height
        char_code += 1
      end
    end

    true
  end
  private :setup_io

  def cleanup
    SDL::DestroyTexture(@texture)
  end

  def set_text(x, y, text, scale = 1.0)
    return if @dst_count >= @dst_rects.length

    current_x = x
    current_y = y

    text.each_char do |ch|
      case ch
      when ' '
        current_x += (@space_width * scale).round
      when "\n"
        current_x = x
        current_y += (@newline_height * scale).round
      else
        code = ch.ord
        r = @dst_rects[@dst_count]
        r.src = @src_rects[code]
        r.dst[:x] = current_x
        r.dst[:y] = current_y
        r.dst[:w] = @src_rects[code][:w] * scale
        r.dst[:h] = @src_rects[code][:h] * scale
        current_x += (@src_rects[code][:w] * scale).round
        @dst_count += 1
      end
    end
  end

  def render(renderer)
    return if @texture.nil?

    @dst_count.times do |i|
      r = @dst_rects[i]
      SDL.RenderTexture(renderer, @texture, r.src, r.dst)
    end

    @dst_count = 0
  end
end

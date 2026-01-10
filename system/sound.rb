require 'sdl3'

module Sound
  def self.setup()
    SDL.MIX_Init()
    @@mixer = SDL.MIX_CreateMixerDevice(SDL::AUDIO_DEVICE_DEFAULT_PLAYBACK, nil)
  end

  def self.cleanup()
    SDL.MIX_DestroyMixer(@@mixer)
    SDL.MIX_Quit()
  end

  def self.mixer = @@mixer

  class Bgm
    def initialize(music_path)
      @path = music_path
    end

    def setup
      @audio = SDL.MIX_LoadAudio_IO(Sound.mixer, SDL.IOFromFile(@path, 'rb'), true, true)
      @track = SDL.MIX_CreateTrack(Sound.mixer)
      @options = SDL.CreateProperties()
      SDL.MIX_SetTrackAudio(@track, @audio)
      self
    end

    def cleanup
      SDL.DestroyProperties(@options)
      SDL.MIX_DestroyTrack(@track)
      SDL.MIX_DestroyAudio(@audio)
      @options = nil
      @track = nil
      @audio = nil
    end

    def play(do_loop: true)
      SDL.MIX_SetTrackLoops(@track, do_loop ? -1 : 0)
      SDL.MIX_PlayTrack(@track, do_loop ? -1 : 0)
    end

    def fadeout(ms: 500)
      SDL.MIX_StopTrack(@track, ms)
    end

    def halt
      SDL.MIX_StopTrack(@track, 0)
    end
  end

  class Sefx
    def initialize(wav_path)
      @path = wav_path
    end

    def setup
      @audio = SDL.MIX_LoadAudio_IO(Sound.mixer, SDL.IOFromFile(@path, 'rb'), true, true)
      @track = SDL.MIX_CreateTrack(Sound.mixer)
      @options = SDL.CreateProperties()
      SDL.MIX_SetTrackAudio(@track, @audio)
      self
    end

    def cleanup
      SDL.DestroyProperties(@options)
      SDL.MIX_DestroyTrack(@track)
      SDL.MIX_DestroyAudio(@audio)
      @options = nil
      @track = nil
      @audio = nil
    end

    def play(do_loop: false)
      SDL.MIX_SetTrackLoops(@track, do_loop ? -1 : 0)
      SDL.MIX_PlayTrack(@track, do_loop ? -1 : 0)
    end
  end
end

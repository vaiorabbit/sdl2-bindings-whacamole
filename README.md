<!-- -*- mode:markdown; coding:utf-8; -*- -->

# Whac-a-Mole! : Ruby SDL3 bindings demo #

*   Created : 2022-05-22
*   Last modified : 2026-01-18

<img src="https://raw.githubusercontent.com/vaiorabbit/sdl2-bindings-whacamole/main/doc/screenshot_00.png" width="300"> <img src="https://raw.githubusercontent.com/vaiorabbit/sdl2-bindings-whacamole/main/doc/screenshot_01.png" width="300">

Demonstration on how to use [Ruby SDL3 bindings](https://github.com/vaiorabbit/sdl3-bindings) (<https://github.com/vaiorabbit/sdl3-bindings>)

*   Movie : Whac-a-Mole! : Ruby SDL2 bindings demo 
    *   [![](http://img.youtube.com/vi/HroP-_EWcg8/mqdefault.jpg)](https://www.youtube.com/watch?v=HroP-_EWcg8)


## Usage ##

*   `$ gem install sdl3-bindings`
*   `$ ruby main.rb`
*   If you want to use your own SDL, SDL_Image and SDL_Mixer,
    *   Edit main.rb to correct paths to dll/dylib seen in SDL.load_lib, or
    *   Put DLLs into `third_party/SDL3`.

## License ##

The zlib/libpng License ( http://opensource.org/licenses/Zlib ).

    Whac-a-Mole! : Ruby SDL3 bindings demo
    Copyright (c) 2022-2026 vaiorabbit <http://twitter.com/vaiorabbit>

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

/* Copyright (C) 2017, Max Bozzi <mjb@mbozzi.com> */
# include "sdl-unique-ptr.hxx"

namespace utility {
  // Generate function implementations for sdl_deleter::operator()().
# define FREE_ME(type, fn_name)                         \
  void sdl_deleter::operator()(type* const thing)       \
    const noexcept { if (thing) SDL_##fn_name(thing); }
  FREE_ME(SDL_RWops, FreeRW)             FREE_ME(SDL_cond, DestroyCond)
  FREE_ME(SDL_Cursor, FreeCursor)        FREE_ME(SDL_PixelFormat, FreeFormat)
  FREE_ME(SDL_mutex, DestroyMutex)       FREE_ME(SDL_Palette, FreePalette)
  FREE_ME(SDL_Renderer, DestroyRenderer) FREE_ME(SDL_sem, DestroySemaphore)
  FREE_ME(SDL_Surface, FreeSurface)      FREE_ME(SDL_Texture, DestroyTexture)
  FREE_ME(Uint8, FreeWAV)                FREE_ME(SDL_Window, DestroyWindow)
# undef FREE_ME
}

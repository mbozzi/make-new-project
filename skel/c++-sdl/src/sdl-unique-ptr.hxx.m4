changecom(//)dnl
define(projectname,translit(projectname,`-a-z"',`_A-Z'))dnl
/* Copyright (C) 2017, Max Bozzi <mjb@mbozzi.com> */

# if ! defined projectname`'_SDL_UNIQUE_PTR_HXX
# define projectname`'_SDL_UNIQUE_PTR_HXX

# include <memory>
# include <SDL2/SDL.h>

/// \brief Utilities namespace.
namespace utility {
  /** \brief Generic deleter functor for SDL resources.
   * For use with std::unique_ptr.
   */
  struct sdl_deleter {
    // Generate "free" declarations.
# define FREE_ME(type) void operator()(type* const thing) const noexcept;
    FREE_ME(SDL_RWops)    FREE_ME(SDL_cond)
    FREE_ME(SDL_Cursor)   FREE_ME(SDL_PixelFormat)
    FREE_ME(SDL_mutex)    FREE_ME(SDL_Palette)
    FREE_ME(SDL_Renderer) FREE_ME(SDL_sem)
    FREE_ME(SDL_Surface)  FREE_ME(SDL_Texture)
    FREE_ME(Uint8)        FREE_ME(SDL_Window)
#undef FREE_ME
  };

  template <typename Resource>
  using sdl_unique_ptr = std::unique_ptr<Resource, sdl_deleter>;

  inline namespace sdl_ptrs {
    using rwops_ptr         = sdl_unique_ptr<SDL_RWops>;
    using cursor_ptr        = sdl_unique_ptr<SDL_Cursor>;
    using mutex_ptr         = sdl_unique_ptr<SDL_mutex>;
    using renderer_ptr      = sdl_unique_ptr<SDL_Renderer>;
    using surface_ptr       = sdl_unique_ptr<SDL_Surface>;
    using wav_ptr           = sdl_unique_ptr<Uint8>;
    using cond_ptr          = sdl_unique_ptr<SDL_cond>;
    using pixel_format_ptr  = sdl_unique_ptr<SDL_PixelFormat>;
    using palette_ptr       = sdl_unique_ptr<SDL_Palette>;
    using sem_ptr           = sdl_unique_ptr<SDL_sem>;
    using texture_ptr       = sdl_unique_ptr<SDL_Texture>;
    using window_ptr        = sdl_unique_ptr<SDL_Window>;
  }
}

# endif

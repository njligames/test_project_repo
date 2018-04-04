
message(STATUS "Platform is windows32 for engine")

set(${CMAKE_PROJECT_NAME}_URL_SDL2_INCLUDE 
  "https://www.dropbox.com/s/g0qrc1xkz2qcb9y/SDL2-2.0.7_include.tar.gz?dl=0" 
  CACHE STRING "The URL for the include files for SDL2")

set(${CMAKE_PROJECT_NAME}_URL_SDL2_LIB_WINDOWS_WIN32_RELEASE 
  "https://www.dropbox.com/s/6khz9t3oizrihrq/SDL2-2.0.7_windows_Win32_Release.tar.gz?dl=0" 
  CACHE STRING "The URL for the Windows 32bit version of SDL2"
  )

set(SDL2_INCLUDE_DIR "thirdparty/SDL2-2.0.7/include")
set(LIBSDL_INCLUDE_URL "${${CMAKE_PROJECT_NAME}_URL_SDL2_INCLUDE}")

RETRIEVE_TAR(
  "${LIBSDL_INCLUDE_URL}"
  "${SDL2_INCLUDE_DIR}"
  "SKIP"
  )

include_directories("${CMAKE_BINARY_DIR}/${SDL2_INCLUDE_DIR}")

set(LIBSDL_LIBRARY_URL "${${CMAKE_PROJECT_NAME}_URL_SDL2_LIB_WINDOWS_WIN32_RELEASE}")
set(LIBSDL_LIBRARY_TARGET_DIRECTORY "thirdparty/SDL2-2.0.7/lib/windows/x86")

RETRIEVE_TAR(
  "${LIBSDL_LIBRARY_URL}"
  "${LIBSDL_LIBRARY_TARGET_DIRECTORY}"
  "SKIP"
  )

set(SDL_IMPORT_LOCATION "${CMAKE_BINARY_DIR}/${LIBSDL_LIBRARY_TARGET_DIRECTORY}/SDL2.${STATIC_LIBRARY_EXTENSION}")
add_library(SDL2_LIBRARY STATIC IMPORTED )
set_target_properties(SDL2_LIBRARY PROPERTIES IMPORTED_LOCATION "${SDL_IMPORT_LOCATION}")
list(APPEND EXTRA_LIBS SDL2_LIBRARY)


set(SDLMAIN_IMPORT_LOCATION "${CMAKE_BINARY_DIR}/${LIBSDL_LIBRARY_TARGET_DIRECTORY}/SDL2main.${STATIC_LIBRARY_EXTENSION}")
add_library(SDL2MAIN_LIBRARY STATIC IMPORTED )
set_target_properties(SDL2MAIN_LIBRARY PROPERTIES IMPORTED_LOCATION "${SDLMAIN_IMPORT_LOCATION}")
list(APPEND EXTRA_LIBS SDL2MAIN_LIBRARY)

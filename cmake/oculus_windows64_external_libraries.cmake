
message(STATUS "Platform is oculus windows64 for engine")

# -------------------------------------------------------------------------------------------------------------------------
# SDL2

set(${CMAKE_PROJECT_NAME}_URL_SDL2_INCLUDE 
  "https://www.dropbox.com/s/g0qrc1xkz2qcb9y/SDL2-2.0.7_include.tar.gz?dl=0" 
  CACHE STRING "The URL for the include files for SDL2")

set(${CMAKE_PROJECT_NAME}_URL_SDL2_LIB_WINDOWS_X64_RELEASE 
  "https://www.dropbox.com/s/8hozs9z89raqyyw/SDL2-2.0.7_windows_x64_Release.tar.gz?dl=0" 
  CACHE STRING "The URL for the Windows 64bit version of SDL2"
  )

set(SDL2_INCLUDE_DIR "thirdparty/SDL2-2.0.7/include")
set(LIBSDL_INCLUDE_URL "${${CMAKE_PROJECT_NAME}_URL_SDL2_INCLUDE}")

RETRIEVE_TAR(
  "${LIBSDL_INCLUDE_URL}"
  "${SDL2_INCLUDE_DIR}"
  "SKIP"
  )

include_directories("${CMAKE_BINARY_DIR}/${SDL2_INCLUDE_DIR}")

set(LIBSDL_LIBRARY_URL "${${CMAKE_PROJECT_NAME}_URL_SDL2_LIB_WINDOWS_X64_RELEASE}")
set(LIBSDL_LIBRARY_TARGET_DIRECTORY "thirdparty/SDL2-2.0.7/lib/windows/x64")

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

# -------------------------------------------------------------------------------------------------------------------------
# Oculus

set(${CMAKE_PROJECT_NAME}_URL_OCULUS_INCLUDE 
  "https://www.dropbox.com/s/93t7xb74oj83agl/LIBOVR_include.tar.gz?dl=0" 
  CACHE STRING "The URL for the include files for Oculus Rift")

set(${CMAKE_PROJECT_NAME}_URL_OCULUS_LIB_WINDOWS_X64_RELEASE 
  "https://www.dropbox.com/s/vnshsaoz52hy877/LIBOVR_windows_win64.tar.gz?dl=0" 
  CACHE STRING "The URL for the Windows 32bit version of Oculus Rift"
  )

set(LIBOVR_INCLUDE_URL "${${CMAKE_PROJECT_NAME}_URL_OCULUS_INCLUDE}")
set(LIBOVR_INCLUDE_DIR "thirdparty/LibOVR/include")

RETRIEVE_TAR(
  "${LIBOVR_INCLUDE_URL}"
  "${LIBOVR_INCLUDE_DIR}"
  "SKIP"
  )

include_directories("${CMAKE_BINARY_DIR}/${LIBOVR_INCLUDE_DIR}")

set(LIBOVR_LIBRARY_URL "${${CMAKE_PROJECT_NAME}_URL_OCULUS_LIB_WINDOWS_X64_RELEASE}")
set(LIBOVR_LIBRARY_TARGET_DIRECTORY "thirdparty/LibOVR/lib/windows/x64")

RETRIEVE_TAR(
  "${LIBOVR_LIBRARY_URL}"
  "${LIBOVR_LIBRARY_TARGET_DIRECTORY}"
  "SKIP"
  )

set(LIBOVR_IMPORT_LOCATION "${CMAKE_BINARY_DIR}/${LIBOVR_LIBRARY_TARGET_DIRECTORY}/LibOVR.${STATIC_LIBRARY_EXTENSION}")
add_library(LIBOVR_LIBRARY STATIC IMPORTED )
set_target_properties(LIBOVR_LIBRARY PROPERTIES IMPORTED_LOCATION "${LIBOVR_IMPORT_LOCATION}")
list(APPEND EXTRA_LIBS LIBOVR_LIBRARY)


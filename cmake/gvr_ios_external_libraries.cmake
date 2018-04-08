
message(STATUS "Platform is gvr ios for engine")

set(${CMAKE_PROJECT_NAME}_URL_SDL2_INCLUDE 
  "https://www.dropbox.com/s/g0qrc1xkz2qcb9y/SDL2-2.0.7_include.tar.gz?dl=0" 
  CACHE STRING "The URL for the include files for SDL2")

set(${CMAKE_PROJECT_NAME}_URL_SDL2_LIB_IOS_RELEASE 
  "https://www.dropbox.com/s/xsvgzfp2h4lk965/SDL2-2.0.7_ios.tar.gz?dl=0" 
  CACHE STRING "The URL for the iOS version of SDL2"
  )

set(SDL2_INCLUDE_DIR "thirdparty/SDL2-2.0.7/include")
set(LIBSDL_INCLUDE_URL "${${CMAKE_PROJECT_NAME}_URL_SDL2_INCLUDE}")

RETRIEVE_TAR(
  "${LIBSDL_INCLUDE_URL}"
  "${SDL2_INCLUDE_DIR}"
  "SKIP"
  )

include_directories("${CMAKE_BINARY_DIR}/${SDL2_INCLUDE_DIR}")

set(LIBSDL_LIBRARY_URL "${${CMAKE_PROJECT_NAME}_URL_SDL2_LIB_IOS_RELEASE}")
set(LIBSDL_LIBRARY_TARGET_DIRECTORY "thirdparty/SDL2-2.0.7/lib/ios")

RETRIEVE_TAR(
  "${LIBSDL_LIBRARY_URL}"
  "${LIBSDL_LIBRARY_TARGET_DIRECTORY}"
  "SKIP"
  )

set(SDL_IMPORT_LOCATION "${CMAKE_BINARY_DIR}/${LIBSDL_LIBRARY_TARGET_DIRECTORY}/Release\$(EFFECTIVE_PLATFORM_NAME)/libSDL2.${STATIC_LIBRARY_EXTENSION}")

add_library(SDL2_LIBRARY STATIC IMPORTED )
set_target_properties(SDL2_LIBRARY PROPERTIES IMPORTED_LOCATION "${SDL_IMPORT_LOCATION}")
list(APPEND EXTRA_LIBS SDL2_LIBRARY)

# --------------------------------------------------------------------------------------------------

set(${CMAKE_PROJECT_NAME}_URL_GVR_INCLUDE 
  "https://www.dropbox.com/s/vwl8uhkbj8nl74y/GVR-1.120.0_include.tar.gz?dl=0" 
  CACHE STRING "The URL for the include files for GVR")

set(${CMAKE_PROJECT_NAME}_URL_GVR_LIB_IOS_RELEASE 
  "https://www.dropbox.com/s/8vxqnj2mk5wc9gn/GVR-1.120.0_ios_Release.tar.gz?dl=0" 
  CACHE STRING "The URL for the iOS version of GVR"
  )

set(LIBGVR_INCLUDE_URL "${${CMAKE_PROJECT_NAME}_URL_GVR_INCLUDE}")
set(GVR_INCLUDE_DIR "thirdparty/GVR-1.120.0/include")

RETRIEVE_TAR(
  "${LIBGVR_INCLUDE_URL}"
  "${GVR_INCLUDE_DIR}"
  "SKIP"
  )

include_directories("${CMAKE_BINARY_DIR}/${GVR_INCLUDE_DIR}")

set(LIBGVR_LIBRARY_URL "${${CMAKE_PROJECT_NAME}_URL_GVR_LIB_IOS_RELEASE}")
set(LIBGVR_LIBRARY_TARGET_DIRECTORY "thirdparty/GVR-1.120.0/lib/ios")

RETRIEVE_TAR(
  "${LIBGVR_LIBRARY_URL}"
  "${LIBGVR_LIBRARY_TARGET_DIRECTORY}"
  "SKIP"
  )

set(GVR_IMPORT_LOCATION "${CMAKE_BINARY_DIR}/${LIBGVR_LIBRARY_TARGET_DIRECTORY}/Release\$(EFFECTIVE_PLATFORM_NAME)/libGVRSDK.${STATIC_LIBRARY_EXTENSION}")

add_library(GVR_LIBRARY STATIC IMPORTED )
set_target_properties(GVR_LIBRARY PROPERTIES IMPORTED_LOCATION "${GVR_IMPORT_LOCATION}")
list(APPEND EXTRA_LIBS GVR_LIBRARY)


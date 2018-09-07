set(LIBRARY_NAME "sdl2")

set(INCLUDE_URL "https://www.dropbox.com/s/ninle2iwebrcpdq/libsdl_include.tar.gz?dl=0")

set(EMSCRIPTEN_DEBUG_URL "https://www.dropbox.com/s/foq0lphgfrcfaws/libsdl2_emscripten_Debug.tar.gz?dl=0")
set(EMSCRIPTEN_RELEASE_URL "https://www.dropbox.com/s/4u4ij8mcz0oym6a/libsdl2_emscripten_Release.tar.gz?dl=0")

set(WINDOWS32_DEBUG_URL "")
set(WINDOWS32_RELEASE_URL "")

set(WINDOWS64_DEBUG_URL "")
set(WINDOWS64_RELEASE_URL "")

set(IOS_DEVICE_DEBUG_URL "https://www.dropbox.com/s/4w6ck8w3rqwbel1/libsdl2_ios_Debug-iphoneos.tar.gz?dl=0")
set(IOS_SIMULATOR_DEBUG_URL "https://www.dropbox.com/s/i9qcfwpqsvkotnx/libsdl2_ios_Debug-iphonesimulator.tar.gz?dl=0")
set(IOS_DEVICE_RELEASE_URL "https://www.dropbox.com/s/fo252tlumnrfgxh/libsdl2_ios_Release-iphoneos.tar.gz?dl=0")
set(IOS_SIMULATOR_RELEASE_URL "https://www.dropbox.com/s/4qa4koq8y1uo7rj/libsdl2_ios_Release-iphonesimulator.tar.gz?dl=0")

set(APPLETV_DEVICE_DEBUG_URL "https://www.dropbox.com/s/b6g40wkyp5v9f0j/libsdl2_ios_Debug-appletvos.tar.gz?dl=0")
set(APPLETV_SIMULATOR_DEBUG_URL "https://www.dropbox.com/s/4jaimt66kl26x6s/libsdl2_ios_Debug-appletvsimulator.tar.gz?dl=0")
set(APPLETV_DEVICE_RELEASE_URL "https://www.dropbox.com/s/ujjsr0wqvmms5d2/libsdl2_ios_Release-appletvos.tar.gz?dl=0")
set(APPLETV_SIMULATOR_RELEASE_URL "https://www.dropbox.com/s/2j8078to0cy9qa9/libsdl2_ios_Release-appletvsimulator.tar.gz?dl=0")

set(MACOS_DEBUG_URL "https://www.dropbox.com/s/nvhp2k3ykm56zw0/libsdl2_macos_Debug.tar.gz?dl=0")
set(MACOS_RELEASE_URL "https://www.dropbox.com/s/80eklswpp6c2fbc/libsdl2_macos_Release.tar.gz?dl=0")

set(LINUX_DEBUG_URL "")
set(LINUX_RELEASE_URL "")

set(UNIX_DEBUG_URL "")
set(UNIX_RELEASE_URL "")

set(ANDROID_arm64-v8a_DEBUG_URL     "")
set(ANDROID_armeabi-v7a_DEBUG_URL   "")
set(ANDROID_x86_64_DEBUG_URL        "")
set(ANDROID_x86_DEBUG_URL           "")

set(ANDROID_arm64-v8a_RELEASE_URL   "")
set(ANDROID_armeabi-v7a_RELEASE_URL "")
set(ANDROID_x86_64_RELEASE_URL      "")
set(ANDROID_x86_RELEASE_URL         "")

###########################################################################################################################

set(PLATFORM_PATH_SUFFIX_RELEASE "Release")
set(PLATFORM_PATH_SUFFIX_DEBUG "Debug")

###########################################################################################################################

string(TOUPPER ${LIBRARY_NAME} LIBRARY_NAME_UPPER)
set(${LIBRARY_NAME_UPPER}_BASE_PATH "thirdparty/${LIBRARY_NAME}")

set(THIRDPARTY_${LIBRARY_NAME_UPPER}_INCLUDE_URL "${INCLUDE_URL}" CACHE STRING "The URL for include Bullet3")
mark_as_advanced(${THIRDPARTY_${LIBRARY_NAME_UPPER}_INCLUDE_URL})

unset(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL CACHE)
unset(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL CACHE)

if(EMSCRIPTEN)
  set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/emscripten")
  if(EMSCRIPTEN_DEBUG_URL)
    set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${EMSCRIPTEN_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
  endif()
  if(EMSCRIPTEN_RELEASE_URL)
    set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${EMSCRIPTEN_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
  endif()
elseif(WINDOWS)
  if(ARCH_64)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/windows64")
    if(WINDOWS64_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${WINDOWS64_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(WINDOWS64_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${WINDOWS64_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()
  else()
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/windows32")
    if(WINDOWS32_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${WINDOWS32_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(WINDOWS32_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${WINDOWS32_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()
  endif()
elseif(APPLE)
  if(IOS)
    set(PLATFORM_PATH_SUFFIX_RELEASE "Release-iphoneos")
    set(PLATFORM_PATH_SUFFIX_DEBUG "Debug-iphoneos")

    set(PLATFORM_SIMULATOR_PATH_SUFFIX_RELEASE "Release-iphonesimulator")
    set(PLATFORM_SIMULATOR_PATH_SUFFIX_DEBUG "Debug-iphonesimulator")

    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/ios")
    if(IOS_DEVICE_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${IOS_DEVICE_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(IOS_DEVICE_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${IOS_DEVICE_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()
    if(IOS_SIMULATOR_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_DEBUG_URL "${IOS_SIMULATOR_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3 in the Simulator")
    endif()
    if(IOS_SIMULATOR_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_RELEASE_URL "${IOS_SIMULATOR_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3 in the Simulator")
    endif()

  elseif(TVOS)
    set(PLATFORM_PATH_SUFFIX_RELEASE "Release-appletvos")
    set(PLATFORM_PATH_SUFFIX_DEBUG "Debug-appletvos")

    set(PLATFORM_SIMULATOR_PATH_SUFFIX_RELEASE "Release-appletvsimulator")
    set(PLATFORM_SIMULATOR_PATH_SUFFIX_DEBUG "Debug-appletvsimulator")

    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/appletv")
    if(APPLETV_DEVICE_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${APPLETV_DEVICE_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(APPLETV_DEVICE_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${APPLETV_DEVICE_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()
    if(APPLETV_SIMULATOR_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_DEBUG_URL "${APPLETV_SIMULATOR_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(APPLETV_SIMULATOR_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_RELEASE_URL "${APPLETV_SIMULATOR_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()

  else()
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/macos")
    if(MACOS_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${MACOS_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(MACOS_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${MACOS_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()
  endif()
elseif(UNIX AND NOT APPLE AND NOT ANDROID)
  if(LINUX)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/linux")
    if(LINUX_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${LINUX_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(LINUX_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${LINUX_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()
  elseif(UNIX)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/unix")
    if(UNIX_DEBUG_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL "${UNIX_DEBUG_URL}" CACHE STRING "The URL for Debug Bullet3")
    endif()
    if(UNIX_RELEASE_URL)
      set(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL "${UNIX_RELEASE_URL}" CACHE STRING "The URL for Release Bullet3")
    endif()
  endif()
elseif(ANDROID)

  set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/android")

  if(ANDROID_${ANDROID_ABI}_DEBUG_URL)
    set(THIRDPARTY_${LIBRARY_NAME_UPPER}_${ANDROID_ABI}_DEBUG_URL ${ANDROID_${ANDROID_ABI}_DEBUG_URL} CACHE STRING "The URL for Bullet3")
    mark_as_advanced(${THIRDPARTY_${LIBRARY_NAME_UPPER}_${ANDROID_ABI}_DEBUG_URL})
    DOWNLOAD_LIBRARY_TAR(
      "${LIBRARY_NAME}"
      "${THIRDPARTY_${LIBRARY_NAME_UPPER}_${ANDROID_ABI}_DEBUG_URL}"
      "${${LIBRARY_NAME_UPPER}_BASE_PATH}/${ANDROID_ABI}/Debug"
      )
    file(GLOB DL_LIBRARIES "${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}/${ANDROID_ABI}/Debug/*.so")
    list(APPEND ${ANDROID_ABI}_LIBRARIES ${DL_LIBRARIES})
  endif()

  if(ANDROID_${ANDROID_ABI}_RELEASE_URL)
    set(THIRDPARTY_${LIBRARY_NAME_UPPER}_${ANDROID_ABI}_RELEASE_URL ${ANDROID_${ANDROID_ABI}_RELEASE_URL} CACHE STRING "The URL for Bullet3")
    mark_as_advanced(${THIRDPARTY_${LIBRARY_NAME_UPPER}_${ANDROID_ABI}_RELEASE_URL})
    DOWNLOAD_LIBRARY_TAR(
      "${LIBRARY_NAME}"
      "${THIRDPARTY_${LIBRARY_NAME_UPPER}_${ANDROID_ABI}_RELEASE_URL}"
      "${${LIBRARY_NAME_UPPER}_BASE_PATH}/${ANDROID_ABI}/Release"
      )
    file(GLOB DL_LIBRARIES "${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}/${ANDROID_ABI}/Release/*.so")
    list(APPEND ${ANDROID_ABI}_LIBRARIES ${DL_LIBRARIES})
  endif()

endif()

if(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL)
  mark_as_advanced(${THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL})
  if(THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL)
    DOWNLOAD_LIBRARY_TAR(
      "${LIBRARY_NAME}"
      "${THIRDPARTY_${LIBRARY_NAME_UPPER}_DEBUG_URL}"
      "${${LIBRARY_NAME_UPPER}_BASE_PATH}/${PLATFORM_PATH_SUFFIX_DEBUG}"
      )
  endif()
endif()

if(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL)
  mark_as_advanced(${THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL})
  if(THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL)
    DOWNLOAD_LIBRARY_TAR(
      "${LIBRARY_NAME}"
      "${THIRDPARTY_${LIBRARY_NAME_UPPER}_RELEASE_URL}"
      "${${LIBRARY_NAME_UPPER}_BASE_PATH}/${PLATFORM_PATH_SUFFIX_RELEASE}"
      )
  endif()
endif()

if(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_DEBUG_URL)
  mark_as_advanced(${THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_DEBUG_URL})
  if(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_DEBUG_URL)
    DOWNLOAD_LIBRARY_TAR(
      "${LIBRARY_NAME}"
      "${THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_DEBUG_URL}"
      "${${LIBRARY_NAME_UPPER}_BASE_PATH}/${PLATFORM_SIMULATOR_PATH_SUFFIX_DEBUG}"
      )
  endif()
endif()

if(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_RELEASE_URL)
  mark_as_advanced(${THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_RELEASE_URL})
  if(THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_RELEASE_URL)
    DOWNLOAD_LIBRARY_TAR(
      "${LIBRARY_NAME}"
      "${THIRDPARTY_${LIBRARY_NAME_UPPER}_SIMULATOR_RELEASE_URL}"
      "${${LIBRARY_NAME_UPPER}_BASE_PATH}/${PLATFORM_SIMULATOR_PATH_SUFFIX_RELEASE}"
      )
  endif()
endif()

if(THIRDPARTY_${LIBRARY_NAME_UPPER}_INCLUDE_URL)
  DOWNLOAD_LIBRARY_INCLUDE_FILES(
    "${LIBRARY_NAME}"
    "${THIRDPARTY_${LIBRARY_NAME_UPPER}_INCLUDE_URL}"
    "${${LIBRARY_NAME_UPPER}_BASE_PATH}/include"
    )

  SUBDIRLIST(SUBDIRS "${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}/include" ${LIBRARY_NAME_UPPER}_INCLUDE_DIRS)
  list(APPEND ${LIBRARY_NAME_UPPER}_INCLUDE_DIRS "${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}/include")
endif()

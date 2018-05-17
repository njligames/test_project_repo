if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "Prevented in-tree built. Please create a build directory outside of the SDL source code and call cmake from there")
endif()

if(IOS AND TVOS)
  message(FATAL_ERROR "Cannot have both IOS and TVOS enabled.")
endif()

# cmake_minimum_required( VERSION 3.11 )
cmake_minimum_required( VERSION 3.5.1 )
project(NJLIC C CXX)

# include(ExternalProject)
# set(EXTERNAL_INSTALL_LOCATION ${CMAKE_BINARY_DIR}/external)
# ExternalProject_Add(engine_code
# 	BUILD_ALWAYS FALSE
#         GIT_REPOSITORY git@github.com:njligames/test_engine_repo.git
#         CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_LOCATION}
#         )

# !!! FIXME: this should probably do "MACOSX_RPATH ON" as a target property
# !!! FIXME:  for the SDL2 shared library (so you get an
# !!! FIXME:  install_name ("soname") of "@rpath/libSDL-whatever.dylib"
# !!! FIXME:  instead of "/usr/local/lib/libSDL-whatever.dylib"), but I'm
# !!! FIXME:  punting for now and leaving the existing behavior. Until this
# !!! FIXME:  properly resolved, this line silences a warning in CMake 3.0+.
# !!! FIXME:  remove it and this comment entirely once the problem is
# !!! FIXME:  properly resolved.
#cmake_policy(SET CMP0042 OLD)

include(CheckFunctionExists)
include(CheckLibraryExists)
include(CheckIncludeFiles)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckCCompilerFlag)
include(CheckTypeSize)
include(CheckStructHasMember)
include(CMakeDependentOption)
include(FindPkgConfig)
include(GNUInstallDirs)

if(VR)
  list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS VR)
endif()

set(CMAKE_MODULE_PATH "${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/cmake")

include(${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/cmake/macros.cmake)
include(${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/cmake/sdlchecks.cmake)
include(${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/cmake/download-extract.cmake)
include(${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/cmake/print-targets.cmake)

set(EXECUTABLE_NAME "PLACEHOLDER" CACHE STRING "The name of the executable")
set(EXECUTABLE_GITHUB_REPOSITORY "test_engine_repo" CACHE STRING "The repository to use from the ")
set(EXECUTABLE_GITHUB_ACCOUNT "njligames" CACHE STRING "The repository to use from the ")

set(${CMAKE_PROJECT_NAME}_REPO_URL "https://github.com/${EXECUTABLE_GITHUB_ACCOUNT}/${EXECUTABLE_GITHUB_REPOSITORY}/archive/master.tar.gz")
set(${CMAKE_PROJECT_NAME}_REPO_DIR "${EXECUTABLE_GITHUB_REPOSITORY}")
RETRIEVE_TAR(
	"${${CMAKE_PROJECT_NAME}_REPO_URL}"
  "${${CMAKE_PROJECT_NAME}_REPO_DIR}"
	"SKIP"
)
set(${CMAKE_PROJECT_NAME}_REPO_DIRECTORY "${CMAKE_BINARY_DIR}/${${CMAKE_PROJECT_NAME}_REPO_DIR}")

set(CMAKEIN_REPO_URL "https://github.com/njligames/cmake.in/archive/master.tar.gz")
set(CMAKEIN_REPO_DIR "cmake.in")
RETRIEVE_TAR(
	"${CMAKEIN_REPO_URL}"
	"${CMAKEIN_REPO_DIR}"
	"SKIP"
)
set(CMAKEIN_REPO_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKEIN_REPO_DIR}")


set(GAMEPROJECT_REPO_URL "https://github.com/njligames/gameproject/archive/master.tar.gz")
set(GAMEPROJECT_REPO_DIR "gameproject")
RETRIEVE_TAR(
	"${GAMEPROJECT_REPO_URL}"
	"${GAMEPROJECT_REPO_DIR}"
	"SKIP"
)
set(GAMEPROJECT_REPO_DIRECTORY "${CMAKE_BINARY_DIR}/${GAMEPROJECT_REPO_DIR}")

# General settings
# Edit include/SDL_version.h and change the version, then:
#   ${CMAKE_PROJECT_NAME}_MICRO_VERSION += 1;
#   ${CMAKE_PROJECT_NAME}_INTERFACE_AGE += 1;
#   ${CMAKE_PROJECT_NAME}_BINARY_AGE += 1;
# if any functions have been added, set ${CMAKE_PROJECT_NAME}_INTERFACE_AGE to 0.
# if backwards compatibility has been broken,
# set ${CMAKE_PROJECT_NAME}_BINARY_AGE and ${CMAKE_PROJECT_NAME}_INTERFACE_AGE to 0.
set(${CMAKE_PROJECT_NAME}_MAJOR_VERSION 0)
set(${CMAKE_PROJECT_NAME}_MINOR_VERSION 0)
set(${CMAKE_PROJECT_NAME}_MICRO_VERSION 1)
set(${CMAKE_PROJECT_NAME}_INTERFACE_AGE 0)
set(${CMAKE_PROJECT_NAME}_BINARY_AGE 0)
set(${CMAKE_PROJECT_NAME}_VERSION "${${CMAKE_PROJECT_NAME}_MAJOR_VERSION}.${${CMAKE_PROJECT_NAME}_MINOR_VERSION}.${${CMAKE_PROJECT_NAME}_MICRO_VERSION}")

list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS ${CMAKE_PROJECT_NAME}_MAJOR_VERSION=\"${${CMAKE_PROJECT_NAME}_MAJOR_VERSION}\")
list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS ${CMAKE_PROJECT_NAME}_MINOR_VERSION=\"${${CMAKE_PROJECT_NAME}_MINOR_VERSION}\")
list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS ${CMAKE_PROJECT_NAME}_MICRO_VERSION=\"${${CMAKE_PROJECT_NAME}_MICRO_VERSION}\")

if(NOT ANDROID)
  # Set defaults preventing destination file conflicts
  set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "Name suffix for debug builds")

  mark_as_advanced(CMAKE_IMPORT_LIBRARY_SUFFIX CMAKE_DEBUG_POSTFIX)
endif()

# Calculate a libtool-like version number
math(EXPR LT_CURRENT "${${CMAKE_PROJECT_NAME}_MICRO_VERSION} - ${${CMAKE_PROJECT_NAME}_INTERFACE_AGE}")
math(EXPR LT_AGE "${${CMAKE_PROJECT_NAME}_BINARY_AGE} - ${${CMAKE_PROJECT_NAME}_INTERFACE_AGE}")
math(EXPR LT_MAJOR "${LT_CURRENT}- ${LT_AGE}")
set(LT_REVISION "${${CMAKE_PROJECT_NAME}_INTERFACE_AGE}")
set(LT_RELEASE "${${CMAKE_PROJECT_NAME}_MAJOR_VERSION}.${${CMAKE_PROJECT_NAME}_MINOR_VERSION}")
set(LT_VERSION "${LT_MAJOR}.${LT_AGE}.${LT_REVISION}")

message(STATUS "${LT_VERSION} :: ${LT_AGE} :: ${LT_REVISION} :: ${LT_CURRENT} :: ${LT_RELEASE}")

# General settings & flags
set(LIBRARY_OUTPUT_DIRECTORY "build")
# Check for 64 or 32 bit
set(SIZEOF_VOIDP ${CMAKE_SIZEOF_VOID_P})
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(ARCH_64 TRUE)
  set(PROCESSOR_ARCH "x64")
else()
  set(ARCH_64 FALSE)
  set(PROCESSOR_ARCH "x86")
endif()
set(LIBNAME ${CMAKE_PROJECT_NAME})
if(NOT LIBTYPE)
  set(LIBTYPE SHARED)
endif()

set(STATIC_LIBRARY_EXTENSION "a")
set(DYNAMIC_LIBRARY_EXTENSION "dylib")

# Get the platform
if(WIN32)
  set(STATIC_LIBRARY_EXTENSION "lib")
  set(DYNAMIC_LIBRARY_EXTENSION "dll")

  if(NOT WINDOWS)
    set(WINDOWS TRUE)
  endif()
elseif(UNIX AND NOT APPLE)
  if(CMAKE_SYSTEM_NAME MATCHES ".*Linux")
    set(LINUX TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "kFreeBSD.*")
    set(FREEBSD TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "kNetBSD.*|NetBSD.*")
    set(NETBSD TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "kOpenBSD.*|OpenBSD.*")
    set(OPENBSD TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES ".*GNU.*")
    set(GNU TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES ".*BSDI.*")
    set(BSDI TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "DragonFly.*|FreeBSD")
    set(FREEBSD TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "SYSV5.*")
    set(SYSV5 TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "Solaris.*")
    set(SOLARIS TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "HP-UX.*")
    set(HPUX TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "AIX.*")
    set(AIX TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "Minix.*")
    set(MINIX TRUE)
  endif()
elseif(APPLE)
  if(CMAKE_SYSTEM_NAME MATCHES ".*Darwin.*")
    set(DARWIN TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES ".*MacOS.*")
    set(MACOSX TRUE)
  endif()
  # TODO: iOS?
elseif(CMAKE_SYSTEM_NAME MATCHES "BeOS.*")
  # message_error("BeOS support has been removed as of SDL 2.0.2.")
elseif(CMAKE_SYSTEM_NAME MATCHES "Haiku.*")
  set(HAIKU TRUE)
endif()

# Don't mistake osx for unix
if(UNIX AND NOT APPLE)
  set(UNIX_SYS ON)
else()
  set(UNIX_SYS OFF)
endif()

if(UNIX OR APPLE)
  set(UNIX_OR_MAC_SYS ON)
else()
  set(UNIX_OR_MAC_SYS OFF)
endif()

if (UNIX_OR_MAC_SYS AND NOT EMSCRIPTEN) # JavaScript does not yet have threading support, so disable pthreads when building for Emscripten.
  set(${CMAKE_PROJECT_NAME}_PTHREADS_ENABLED_BY_DEFAULT ON)
else()
  set(${CMAKE_PROJECT_NAME}_PTHREADS_ENABLED_BY_DEFAULT OFF)
endif()

# Default option knobs
if(APPLE OR ARCH_64)
  if(NOT "${CMAKE_OSX_ARCHITECTURES}" MATCHES "arm")
    set(OPT_DEF_SSEMATH ON)
  endif()
endif()
if(UNIX OR MINGW OR MSYS)
  set(OPT_DEF_LIBC ON)
endif()

# Compiler info
if(CMAKE_COMPILER_IS_GNUCC)
  set(USE_GCC TRUE)
  set(OPT_DEF_ASM TRUE)
elseif(CMAKE_C_COMPILER_ID MATCHES "Clang")
  set(USE_CLANG TRUE)
  set(OPT_DEF_ASM TRUE)
elseif(MSVC_VERSION GREATER 1400) # VisualStudio 8.0+
  set(OPT_DEF_ASM TRUE)
  #set(CMAKE_C_FLAGS "/ZI /WX- /
else()
  set(OPT_DEF_ASM FALSE)
endif()

if(USE_GCC OR USE_CLANG)
  set(OPT_DEF_GCC_ATOMICS ON)
  set(CMAKE_CXX_FLAGS "-std=c++11 -fno-exceptions")
endif()

# Default flags, if not set otherwise
if("$ENV{CFLAGS}" STREQUAL "")
  if(CMAKE_BUILD_TYPE STREQUAL "")
    if(USE_GCC OR USE_CLANG)
      set(CMAKE_BUILD_TYPE "Debug")
    endif()
  endif()
else()
  set(CMAKE_C_FLAGS "$ENV{CFLAGS}")
  list(APPEND EXTRA_CFLAGS "$ENV{CFLAGS}")
endif()
list(APPEND EXTRA_CFLAGS "-pedantic")

if(NOT ("$ENV{CFLAGS}" STREQUAL "")) # Hackish, but does the trick on Win32
  list(APPEND EXTRA_LDFLAGS "$ENV{LDFLAGS}")
endif()

if(MSVC)
  option(FORCE_STATIC_VCRT "Force /MT for static VC runtimes" OFF)
  if(FORCE_STATIC_VCRT)
    foreach(flag_var
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)
      if(${flag_var} MATCHES "/MD")
        string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
      endif()
    endforeach()
  endif()

  # Make sure /RTC1 is disabled, otherwise it will use functions from the CRT
  foreach(flag_var
      CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
      CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)
    string(REGEX REPLACE "/RTC(su|[1su])" "" ${flag_var} "${${flag_var}}")
  endforeach(flag_var)
endif()

# Those are used for pkg-config and friends, so that the ${CMAKE_PROJECT_NAME}.pc, njlic-config,
# etc. are created correctly.
set(${CMAKE_PROJECT_NAME}_LIBS "-l${CMAKE_PROJECT_NAME}")
set(${CMAKE_PROJECT_NAME}_CFLAGS "")

# Emscripten toolchain has a nonempty default value for this, and the checks 
# in this file need to change that, so remember the original value, and 
# restore back to that afterwards. For check_function_exists() to work in
# Emscripten, this value must be at its default value.
set(ORIG_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})

if(CYGWIN)
  # We build ${CMAKE_PROJECT_NAME} on cygwin without the UNIX emulation layer
  include_directories("-I/usr/include/mingw")
  set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -mno-cygwin")
  check_c_source_compiles("int main(int argc, char **argv) {}"
    HAVE_GCC_NO_CYGWIN)
  set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
  if(HAVE_GCC_NO_CYGWIN)
    list(APPEND EXTRA_LDFLAGS "-mno-cygwin")
    list(APPEND ${CMAKE_PROJECT_NAME}_LIBS "-mno-cygwin")
  endif()
  set(${CMAKE_PROJECT_NAME}_CFLAGS "${${CMAKE_PROJECT_NAME}_CFLAGS} -I/usr/include/mingw")
endif()

# list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS -DUSING_GENERATED_CONFIG_H)
if(USE_GCC OR USE_CLANG)
  # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -idirafter ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/khronos")
else()
  # include_directories(${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/khronos)
endif()

# All these ENABLED_BY_DEFAULT vars will default to ON if not specified, so
#  you only need to have a platform override them if they are disabling.
set(OPT_DEF_ASM TRUE)
if(EMSCRIPTEN)
  set(CMAKE_CXX_FLAGS_DEBUG "--js-opts 0 -g4")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "-Os -DNDEBUG --llvm-opts 3 --js-opts 1 --closure 1")
  set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG --llvm-opts 3 --js-opts 1 --closure 1")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 --js-opts 0 -g4 -DNDEBUG")

  set(CMAKE_C_FLAGS_DEBUG "--js-opts 0 -g4")
  set(CMAKE_C_FLAGS_MINSIZEREL "-Os -DNDEBUG --llvm-opts 3 --js-opts 1 --closure 1")
  set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG --llvm-opts 3 --js-opts 1 --closure 1")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 --js-opts 0 -g4 -DNDEBUG")

  # list(APPEND EXTRA_LDFLAGS "-s USE_PTHREADS=2")
  # list(APPEND EXTRA_LDFLAGS "-s PTHREAD_POOL_SIZE=8")
  list(APPEND EXTRA_LDFLAGS "-s FULL_ES2=1")
  list(APPEND EXTRA_LDFLAGS "-s TOTAL_MEMORY=256*1024*1024")
  # list(APPEND EXTRA_LDFLAGS "-s WASM=1")
  list(APPEND EXTRA_LDFLAGS "-v")


  if(FACEBOOK)
    if( NOT FACEBOOK-APP-ID )
      error( "There must be a facebook app id set." )
    endif()

    if( NOT FACEBOOK-API-VERSION )
      error( "There must be a facebook version set." )
    endif()

    configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/facebook/facebook_shell.html.in"
      "${CMAKE_BINARY_DIR}/facebook_shell.html")

    configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/facebook/facebook.js.in"
      "${CMAKE_BINARY_DIR}/facebook.js")

    list(APPEND EXTRA_LDFLAGS "--shell-file ${CMAKE_BINARY_DIR}/facebook_shell.html")
    list(APPEND EXTRA_LDFLAGS "--pre-js ${CMAKE_BINARY_DIR}/facebook.js")
  else()
    configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/emscripten/executable/release_shell.html.in"
      "${CMAKE_BINARY_DIR}/release_shell.html")

    list(APPEND EXTRA_LDFLAGS "--shell-file ${CMAKE_BINARY_DIR}/release_shell.html")
  endif()
  
  # Set up default values for the currently supported set of subsystems:
  # Emscripten/Javascript does not have assembly support, a dynamic library 
  # loading architecture, low-level CPU inspection or multithreading.
  set(OPT_DEF_ASM FALSE)
  set(${CMAKE_PROJECT_NAME}_SHARED_ENABLED_BY_DEFAULT OFF)
  set(${CMAKE_PROJECT_NAME}_ATOMIC_ENABLED_BY_DEFAULT OFF)
  set(${CMAKE_PROJECT_NAME}_THREADS_ENABLED_BY_DEFAULT OFF)
  set(${CMAKE_PROJECT_NAME}_LOADSO_ENABLED_BY_DEFAULT OFF)
  set(${CMAKE_PROJECT_NAME}_CPUINFO_ENABLED_BY_DEFAULT OFF)
  set(${CMAKE_PROJECT_NAME}_DLOPEN_ENABLED_BY_DEFAULT OFF)
endif()

if(ANDROID)
  set(${CMAKE_PROJECT_NAME}_STATIC_ENABLED_BY_DEFAULT OFF)
  set(${CMAKE_PROJECT_NAME}_EXE_ENABLED_BY_DEFAULT OFF)
endif()

if (NOT DEFINED ${CMAKE_PROJECT_NAME}_SHARED_ENABLED_BY_DEFAULT)
    set(${CMAKE_PROJECT_NAME}_SHARED_ENABLED_BY_DEFAULT ON)
endif()

if (NOT DEFINED ${CMAKE_PROJECT_NAME}_STATIC_ENABLED_BY_DEFAULT)
    set(${CMAKE_PROJECT_NAME}_STATIC_ENABLED_BY_DEFAULT ON)
endif()

if (NOT DEFINED ${CMAKE_PROJECT_NAME}_EXE_ENABLED_BY_DEFAULT)
    set(${CMAKE_PROJECT_NAME}_EXE_ENABLED_BY_DEFAULT ON)
endif()

set(SDL_SUBSYSTEMS
    Atomic Audio Video Render Events Joystick Haptic Power Threads Timers
    File Loadso CPUinfo Filesystem Dlopen)
foreach(_SUB ${SDL_SUBSYSTEMS})
  string(TOUPPER ${_SUB} _OPT)
  if (NOT DEFINED SDL_${_OPT}_ENABLED_BY_DEFAULT)
    set(SDL_${_OPT}_ENABLED_BY_DEFAULT ON)
  endif()
  option(SDL_${_OPT} "Enable the ${_SUB} subsystem" ${SDL_${_OPT}_ENABLED_BY_DEFAULT})
endforeach()

option_string(ASSERTIONS "Enable internal sanity checks (auto/disabled/release/enabled/paranoid)" "auto")
#set_option(DEPENDENCY_TRACKING "Use gcc -MMD -MT dependency tracking" ON)
set_option(LIBC                "Use the system C library" ${OPT_DEF_LIBC})
set_option(GCC_ATOMICS         "Use gcc builtin atomics" ${OPT_DEF_GCC_ATOMICS})
set_option(ASSEMBLY            "Enable assembly routines" ${OPT_DEF_ASM})
set_option(SSEMATH             "Allow GCC to use SSE floating point math" ${OPT_DEF_SSEMATH})
set_option(MMX                 "Use MMX assembly routines" ${OPT_DEF_ASM})
set_option(3DNOW               "Use 3Dnow! MMX assembly routines" ${OPT_DEF_ASM})
set_option(SSE                 "Use SSE assembly routines" ${OPT_DEF_ASM})
set_option(SSE2                "Use SSE2 assembly routines" ${OPT_DEF_SSEMATH})
set_option(SSE3                "Use SSE3 assembly routines" ${OPT_DEF_SSEMATH})
set_option(ALTIVEC             "Use Altivec assembly routines" ${OPT_DEF_ASM})
set_option(DISKAUDIO           "Support the disk writer audio driver" ON)
set_option(DUMMYAUDIO          "Support the dummy audio driver" ON)
set_option(VIDEO_DIRECTFB      "Use DirectFB video driver" OFF)
dep_option(DIRECTFB_SHARED     "Dynamically load directfb support" ON "VIDEO_DIRECTFB" OFF)
set_option(VIDEO_DUMMY         "Use dummy video driver" ON)
set_option(VIDEO_OPENGL        "Include OpenGL support" ON)
set_option(VIDEO_OPENGLES      "Include OpenGL ES support" ON)
set_option(PTHREADS            "Use POSIX threads for multi-threading" ${${CMAKE_PROJECT_NAME}_PTHREADS_ENABLED_BY_DEFAULT})
dep_option(PTHREADS_SEM        "Use pthread semaphores" ON "PTHREADS" OFF)
set_option(${CMAKE_PROJECT_NAME}_DLOPEN          "Use dlopen for shared object loading" ${${CMAKE_PROJECT_NAME}_DLOPEN_ENABLED_BY_DEFAULT})
set_option(OSS                 "Support the OSS audio API" ${UNIX_SYS})
set_option(ALSA                "Support the ALSA audio API" ${UNIX_SYS})
dep_option(ALSA_SHARED         "Dynamically load ALSA audio support" ON "ALSA" OFF)
set_option(JACK                "Support the JACK audio API" ${UNIX_SYS})
dep_option(JACK_SHARED         "Dynamically load JACK audio support" ON "JACK" OFF)
set_option(ESD                 "Support the Enlightened Sound Daemon" ${UNIX_SYS})
dep_option(ESD_SHARED          "Dynamically load ESD audio support" ON "ESD" OFF)
set_option(PULSEAUDIO          "Use PulseAudio" ${UNIX_SYS})
dep_option(PULSEAUDIO_SHARED   "Dynamically load PulseAudio support" ON "PULSEAUDIO" OFF)
set_option(ARTS                "Support the Analog Real Time Synthesizer" ${UNIX_SYS})
dep_option(ARTS_SHARED         "Dynamically load aRts audio support" ON "ARTS" OFF)
set_option(NAS                 "Support the NAS audio API" ${UNIX_SYS})
set_option(NAS_SHARED          "Dynamically load NAS audio API" ${UNIX_SYS})
set_option(SNDIO               "Support the sndio audio API" ${UNIX_SYS})
set_option(FUSIONSOUND         "Use FusionSound audio driver" OFF)
dep_option(FUSIONSOUND_SHARED  "Dynamically load fusionsound audio support" ON "FUSIONSOUND" OFF)
set_option(LIBSAMPLERATE       "Use libsamplerate for audio rate conversion" ${UNIX_SYS})
dep_option(LIBSAMPLERATE_SHARED "Dynamically load libsamplerate" ON "LIBSAMPLERATE" OFF)
set_option(RPATH               "Use an rpath when linking ${CMAKE_PROJECT_NAME}" ${UNIX_SYS})
set_option(CLOCK_GETTIME       "Use clock_gettime() instead of gettimeofday()" OFF)
set_option(INPUT_TSLIB         "Use the Touchscreen library for input" ${UNIX_SYS})
set_option(VIDEO_X11           "Use X11 video driver" ${UNIX_SYS})
set_option(VIDEO_WAYLAND       "Use Wayland video driver" ${UNIX_SYS})
dep_option(WAYLAND_SHARED      "Dynamically load Wayland support" ON "VIDEO_WAYLAND" OFF)
dep_option(VIDEO_WAYLAND_QT_TOUCH  "QtWayland server support for Wayland video driver" ON "VIDEO_WAYLAND" OFF)
set_option(VIDEO_MIR           "Use Mir video driver" ${UNIX_SYS})
dep_option(MIR_SHARED          "Dynamically load Mir support" ON "VIDEO_MIR" OFF)
set_option(VIDEO_RPI           "Use Raspberry Pi video driver" ${UNIX_SYS})
dep_option(X11_SHARED          "Dynamically load X11 support" ON "VIDEO_X11" OFF)
set(SDL_X11_OPTIONS Xcursor Xinerama XInput Xrandr Xscrnsaver XShape Xvm)
foreach(_SUB ${SDL_X11_OPTIONS})
  string(TOUPPER "VIDEO_X11_${_SUB}" _OPT)
  dep_option(${_OPT}           "Enable ${_SUB} support" ON "VIDEO_X11" OFF)
endforeach()
set_option(VIDEO_COCOA         "Use Cocoa video driver" ${APPLE})
set_option(DIRECTX             "Use DirectX for Windows audio/video" OFF)
set_option(RENDER_D3D          "Enable the Direct3D render driver" OFF)
set_option(VIDEO_VIVANTE       "Use Vivante EGL video driver" ${UNIX_SYS})
dep_option(VIDEO_VULKAN        "Enable Vulkan support" ON "ANDROID OR APPLE OR LINUX OR WINDOWS" OFF)
set_option(VIDEO_KMSDRM        "Use KMS DRM video driver" ${UNIX_SYS})
dep_option(KMSDRM_SHARED       "Dynamically load KMS DRM support" ON "VIDEO_KMSDRM" OFF)

# TODO: We should (should we?) respect cmake's ${BUILD_SHARED_LIBS} flag here
# The options below are for compatibility to configure's default behaviour.
set(${CMAKE_PROJECT_NAME}_SHARED ${${CMAKE_PROJECT_NAME}_SHARED_ENABLED_BY_DEFAULT} CACHE BOOL "Build a shared version of the library")
set(${CMAKE_PROJECT_NAME}_STATIC ${${CMAKE_PROJECT_NAME}_STATIC_ENABLED_BY_DEFAULT} CACHE BOOL "Build a static version of the library")
set(${CMAKE_PROJECT_NAME}_EXE ${${CMAKE_PROJECT_NAME}_EXE_ENABLED_BY_DEFAULT} CACHE BOOL "Build the executable of ${CMAKE_PROJECT_NAME}")

dep_option(${CMAKE_PROJECT_NAME}_STATIC_PIC      "Static version of the library should be built with Position Independent Code" OFF "${CMAKE_PROJECT_NAME}_STATIC" OFF)

include("${${CMAKE_PROJECT_NAME}_REPO_DIRECTORY}/cmake/sources.cmake")

foreach(_SOURCE_FILE ${SOURCE_FILES})
  MESSAGE(STATUS "_SOURCE_FILE ${_SOURCE_FILE}")
endforeach()

get_property(_INCLUDE_DIRECTORIES DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
foreach(_INCLUDE_DIRECTORY ${_INCLUDE_DIRECTORIES})
  MESSAGE(STATUS "_INCLUDE_DIRECTORY ${_INCLUDE_DIRECTORY}")
endforeach()

if(ASSERTIONS STREQUAL "auto")
  # Do nada - use optimization settings to determine the assertion level
elseif(ASSERTIONS STREQUAL "disabled")
  set(${CMAKE_PROJECT_NAME}_DEFAULT_ASSERT_LEVEL 0)
elseif(ASSERTIONS STREQUAL "release")
  set(${CMAKE_PROJECT_NAME}_DEFAULT_ASSERT_LEVEL 1)
elseif(ASSERTIONS STREQUAL "enabled")
  set(${CMAKE_PROJECT_NAME}_DEFAULT_ASSERT_LEVEL 2)
elseif(ASSERTIONS STREQUAL "paranoid")
  set(${CMAKE_PROJECT_NAME}_DEFAULT_ASSERT_LEVEL 3)
else()
  message_error("unknown assertion level")
endif()
set(HAVE_ASSERTIONS ${ASSERTIONS})

# Compiler option evaluation
if(USE_GCC OR USE_CLANG)
  # Check for -Wall first, so later things can override pieces of it.
  check_c_compiler_flag(-Wall HAVE_GCC_WALL)
  if(HAVE_GCC_WALL)
    list(APPEND EXTRA_CFLAGS "-Wall")
    if(HAIKU)
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-multichar")
    endif()
  endif()

  check_c_compiler_flag(-Wdeclaration-after-statement HAVE_GCC_WDECLARATION_AFTER_STATEMENT)
  if(HAVE_GCC_WDECLARATION_AFTER_STATEMENT)
    check_c_compiler_flag(-Werror=declaration-after-statement HAVE_GCC_WERROR_DECLARATION_AFTER_STATEMENT)
    if(HAVE_GCC_WERROR_DECLARATION_AFTER_STATEMENT)
      list(APPEND EXTRA_CFLAGS "-Werror=declaration-after-statement")
    endif()
    list(APPEND EXTRA_CFLAGS "-Wdeclaration-after-statement")
  endif()

  if(DEPENDENCY_TRACKING)
    check_c_source_compiles("
        #if !defined(__GNUC__) || __GNUC__ < 3
        #error Dependency tracking requires GCC 3.0 or newer
        #endif
        int main(int argc, char **argv) { }" HAVE_DEPENDENCY_TRACKING)
  endif()

  if(GCC_ATOMICS)
    check_c_source_compiles("int main(int argc, char **argv) {
        int a;
        void *x, *y, *z;
        __sync_lock_test_and_set(&a, 4);
        __sync_lock_test_and_set(&x, y);
        __sync_fetch_and_add(&a, 1);
        __sync_bool_compare_and_swap(&a, 5, 10);
        __sync_bool_compare_and_swap(&x, y, z); }" HAVE_GCC_ATOMICS)
    if(NOT HAVE_GCC_ATOMICS)
      check_c_source_compiles("int main(int argc, char **argv) {
          int a;
          __sync_lock_test_and_set(&a, 1);
          __sync_lock_release(&a); }" HAVE_GCC_SYNC_LOCK_TEST_AND_SET)
    endif()
  endif()

  set(CMAKE_REQUIRED_FLAGS "-mpreferred-stack-boundary=2")
  check_c_source_compiles("int x = 0; int main(int argc, char **argv) {}"
    HAVE_GCC_PREFERRED_STACK_BOUNDARY)
  set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})

  set(CMAKE_REQUIRED_FLAGS "-fvisibility=hidden -Werror")
  check_c_source_compiles("
      #if !defined(__GNUC__) || __GNUC__ < 4
      #error ${CMAKE_PROJECT_NAME} only uses visibility attributes in GCC 4 or newer
      #endif
      int main(int argc, char **argv) {}" HAVE_GCC_FVISIBILITY)
  if(HAVE_GCC_FVISIBILITY)
    list(APPEND EXTRA_CFLAGS "-fvisibility=hidden")
  endif()
  set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})

  check_c_compiler_flag(-Wshadow HAVE_GCC_WSHADOW)
  if(HAVE_GCC_WSHADOW)
    list(APPEND EXTRA_CFLAGS "-Wshadow")
  endif()

  if(APPLE)
    list(APPEND EXTRA_LDFLAGS "-Wl,-undefined,error")
  else()
    set(CMAKE_REQUIRED_FLAGS "-Wl,--no-undefined")
    check_c_compiler_flag("" HAVE_NO_UNDEFINED)
    set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
    if(HAVE_NO_UNDEFINED)
      list(APPEND EXTRA_LDFLAGS "-Wl,--no-undefined")
    endif()
  endif()
endif()

if(ASSEMBLY)
  if(USE_GCC OR USE_CLANG)
    set(${CMAKE_PROJECT_NAME}_ASSEMBLY_ROUTINES 1)
    # TODO: Those all seem to be quite GCC specific - needs to be
    # reworked for better compiler support
    set(HAVE_ASSEMBLY TRUE)
    if(MMX)
      set(CMAKE_REQUIRED_FLAGS "-mmmx")
      check_c_source_compiles("
          #ifdef __MINGW32__
          #include <_mingw.h>
          #ifdef __MINGW64_VERSION_MAJOR
          #include <intrin.h>
          #else
          #include <mmintrin.h>
          #endif
          #else
          #include <mmintrin.h>
          #endif
          #ifndef __MMX__
          #error Assembler CPP flag not enabled
          #endif
          int main(int argc, char **argv) { }" HAVE_MMX)
      if(HAVE_MMX)
        list(APPEND EXTRA_CFLAGS "-mmmx")
      endif()
      set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
    endif()

    if(3DNOW)
      set(CMAKE_REQUIRED_FLAGS "-m3dnow")
      check_c_source_compiles("
          #include <mm3dnow.h>
          #ifndef __3dNOW__
          #error Assembler CPP flag not enabled
          #endif
          int main(int argc, char **argv) {
            void *p = 0;
            _m_prefetch(p);
          }" HAVE_3DNOW)
      if(HAVE_3DNOW)
        list(APPEND EXTRA_CFLAGS "-m3dnow")
      endif()
      set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
    endif()

    if(SSE)
      set(CMAKE_REQUIRED_FLAGS "-msse")
      check_c_source_compiles("
          #ifdef __MINGW32__
          #include <_mingw.h>
          #ifdef __MINGW64_VERSION_MAJOR
          #include <intrin.h>
          #else
          #include <xmmintrin.h>
          #endif
          #else
          #include <xmmintrin.h>
          #endif
          #ifndef __SSE__
          #error Assembler CPP flag not enabled
          #endif
          int main(int argc, char **argv) { }" HAVE_SSE)
      if(HAVE_SSE)
        list(APPEND EXTRA_CFLAGS "-msse")
      endif()
      set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
    endif()

    if(SSE2)
      set(CMAKE_REQUIRED_FLAGS "-msse2")
      check_c_source_compiles("
          #ifdef __MINGW32__
          #include <_mingw.h>
          #ifdef __MINGW64_VERSION_MAJOR
          #include <intrin.h>
          #else
          #include <emmintrin.h>
          #endif
          #else
          #include <emmintrin.h>
          #endif
          #ifndef __SSE2__
          #error Assembler CPP flag not enabled
          #endif
          int main(int argc, char **argv) { }" HAVE_SSE2)
      if(HAVE_SSE2)
        list(APPEND EXTRA_CFLAGS "-msse2")
      endif()
      set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
    endif()

    if(SSE3)
      set(CMAKE_REQUIRED_FLAGS "-msse3")
      check_c_source_compiles("
          #ifdef __MINGW32__
          #include <_mingw.h>
          #ifdef __MINGW64_VERSION_MAJOR
          #include <intrin.h>
          #else
          #include <pmmintrin.h>
          #endif
          #else
          #include <pmmintrin.h>
          #endif
          #ifndef __SSE3__
          #error Assembler CPP flag not enabled
          #endif
          int main(int argc, char **argv) { }" HAVE_SSE3)
      if(HAVE_SSE3)
        list(APPEND EXTRA_CFLAGS "-msse3")
      endif()
      set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
    endif()

    if(NOT SSEMATH)
      if(SSE OR SSE2 OR SSE3)
        if(USE_GCC)
          check_c_compiler_flag(-mfpmath=387 HAVE_FP_387)
          if(HAVE_FP_387)
            list(APPEND EXTRA_CFLAGS "-mfpmath=387")
          endif()
        endif()
        set(HAVE_SSEMATH TRUE)
      endif()
    endif()

    if(ALTIVEC)
      set(CMAKE_REQUIRED_FLAGS "-maltivec")
      check_c_source_compiles("
          #include <altivec.h>
          vector unsigned int vzero() {
              return vec_splat_u32(0);
          }
          int main(int argc, char **argv) { }" HAVE_ALTIVEC_H_HDR)
      check_c_source_compiles("
          vector unsigned int vzero() {
              return vec_splat_u32(0);
          }
          int main(int argc, char **argv) { }" HAVE_ALTIVEC)
      set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
      if(HAVE_ALTIVEC OR HAVE_ALTIVEC_H_HDR)
        set(HAVE_ALTIVEC TRUE) # if only HAVE_ALTIVEC_H_HDR is set
        list(APPEND EXTRA_CFLAGS "-maltivec")
        set(${CMAKE_PROJECT_NAME}_ALTIVEC_BLITTERS 1)
        if(HAVE_ALTIVEC_H_HDR)
          set(HAVE_ALTIVEC_H 1)
        endif()
      endif()
    endif()
  elseif(MSVC_VERSION GREATER 1500)
    # TODO: SDL_cpuinfo.h needs to support the user's configuration wish
    # for MSVC - right now it is always activated
    if(NOT ARCH_64)
      set(HAVE_MMX TRUE)
      set(HAVE_3DNOW TRUE)
    endif()
    set(HAVE_SSE TRUE)
    set(HAVE_SSE2 TRUE)
    set(HAVE_SSE3 TRUE)
    set(${CMAKE_PROJECT_NAME}_ASSEMBLY_ROUTINES 1)
  endif()
# TODO:
#else()
#  if(USE_GCC OR USE_CLANG)
#    list(APPEND EXTRA_CFLAGS "-mno-sse" "-mno-sse2" "-mno-sse3" "-mno-mmx")
#  endif()
endif()

# TODO: Can't deactivate on FreeBSD? w/o LIBC, SDL_stdinc.h can't define
# anything.
if(LIBC)
  if(WINDOWS AND NOT MINGW)
    set(HAVE_LIBC TRUE)
    foreach(_HEADER stdio.h string.h wchar.h ctype.h math.h limits.h)
      string(TOUPPER "HAVE_${_HEADER}" _UPPER)
      string(REPLACE "." "_" _HAVE_H ${_UPPER})
      set(${_HAVE_H} 1)
    endforeach()
    set(HAVE_SIGNAL_H 1)
    foreach(_FN
            malloc calloc realloc free qsort abs memset memcpy memmove memcmp
            wcslen wcscmp
            strlen _strrev _strupr _strlwr strchr strrchr strstr itoa _ltoa
            _ultoa strtol strtoul strtoll strtod atoi atof strcmp strncmp
            _stricmp _strnicmp sscanf atan atan2 acos asin ceil copysign cos
            cosf fabs floor log pow scalbn sin sinf sqrt sqrtf tan tanf)
      string(TOUPPER ${_FN} _UPPER)
      set(HAVE_${_UPPER} 1)
    endforeach()
    if(NOT CYGWIN AND NOT MINGW)
      set(HAVE_ALLOCA 1)
    endif()
    set(HAVE_M_PI 1)
    list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS _USE_MATH_DEFINES) # needed for M_PI
    set(STDC_HEADERS 1)
  else()
    set(HAVE_LIBC TRUE)
    check_include_file(sys/types.h HAVE_SYS_TYPES_H)
    foreach(_HEADER
            stdio.h stdlib.h stddef.h stdarg.h malloc.h memory.h string.h limits.h
            strings.h wchar.h inttypes.h stdint.h ctype.h math.h iconv.h signal.h libunwind.h)
      string(TOUPPER "HAVE_${_HEADER}" _UPPER)
      string(REPLACE "." "_" _HAVE_H ${_UPPER})
      check_include_file("${_HEADER}" ${_HAVE_H})
    endforeach()

    check_include_files("dlfcn.h;stdint.h;stddef.h;inttypes.h;stdlib.h;strings.h;string.h;float.h" STDC_HEADERS)
    check_type_size("size_t" SIZEOF_SIZE_T)
    check_symbol_exists(M_PI math.h HAVE_M_PI)
    # TODO: refine the mprotect check
    check_c_source_compiles("#include <sys/types.h>
                             #include <sys/mman.h>
                             int main() { }" HAVE_MPROTECT)
    foreach(_FN
            strtod malloc calloc realloc free getenv setenv putenv unsetenv
            qsort abs bcopy memset memcpy memmove memcmp strlen strlcpy strlcat
            _strrev _strupr _strlwr strchr strrchr strstr itoa _ltoa
            _uitoa _ultoa strtol strtoul _i64toa _ui64toa strtoll strtoull
            atoi atof strcmp strncmp _stricmp strcasecmp _strnicmp strncasecmp
            vsscanf vsnprintf fopen64 fseeko fseeko64 sigaction setjmp
            nanosleep sysconf sysctlbyname getauxval poll
            )
      string(TOUPPER ${_FN} _UPPER)
      set(_HAVEVAR "HAVE_${_UPPER}")
      check_function_exists("${_FN}" ${_HAVEVAR})
    endforeach()

    check_library_exists(m pow "" HAVE_LIBM)
    if(HAVE_LIBM)
      set(CMAKE_REQUIRED_LIBRARIES m)
      foreach(_FN
              atan atan2 ceil copysign cos cosf fabs floor log pow scalbn sin
              sinf sqrt sqrtf tan tanf acos asin)
        string(TOUPPER ${_FN} _UPPER)
        set(_HAVEVAR "HAVE_${_UPPER}")
        check_function_exists("${_FN}" ${_HAVEVAR})
      endforeach()
      set(CMAKE_REQUIRED_LIBRARIES)
      list(APPEND EXTRA_LIBS m)
    endif()

    check_library_exists(iconv iconv_open "" HAVE_LIBICONV)
    if(HAVE_LIBICONV)
      list(APPEND EXTRA_LIBS iconv)
      set(HAVE_ICONV 1)
    endif()

    if(NOT APPLE)
      check_include_file(alloca.h HAVE_ALLOCA_H)
      check_function_exists(alloca HAVE_ALLOCA)
    else()
      set(HAVE_ALLOCA_H 1)
      set(HAVE_ALLOCA 1)
    endif()

    check_struct_has_member("struct sigaction" "sa_sigaction" "signal.h" HAVE_SA_SIGACTION)
  endif()
else()
  if(WINDOWS)
    set(HAVE_STDARG_H 1)
    set(HAVE_STDDEF_H 1)
  endif()
endif()


# Enable/disable various subsystems of the SDL library
foreach(_SUB ${SDL_SUBSYSTEMS})
  string(TOUPPER ${_SUB} _OPT)
  if(NOT SDL_${_OPT})
    set(SDL_${_OPT}_DISABLED 1)
  endif()
endforeach()
if(SDL_JOYSTICK)
  # file(GLOB JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${JOYSTICK_SOURCES})
endif()
if(SDL_HAPTIC)
  if(NOT SDL_JOYSTICK)
    # Haptic requires some private functions from the joystick subsystem.
    message_error("SDL_HAPTIC requires SDL_JOYSTICK, which is not enabled")
  endif()
  # file(GLOB HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${HAPTIC_SOURCES})
endif()
if(SDL_POWER)
  # file(GLOB POWER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/power/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${POWER_SOURCES})
endif()
# TODO: in configure.in, the test for LOADSO and ${CMAKE_PROJECT_NAME}_DLOPEN is a bit weird:
# if LOADSO is not wanted, SDL_LOADSO_DISABLED is set
# If however on Unix or APPLE dlopen() is detected via CheckDLOPEN(),
# SDL_LOADSO_DISABLED will not be set, regardless of the LOADSO settings

# General SDL subsystem options, valid for all platforms
if(SDL_AUDIO)
  # CheckDummyAudio/CheckDiskAudio - valid for all platforms
  if(DUMMYAUDIO)
    set(SDL_AUDIO_DRIVER_DUMMY 1)
    # file(GLOB DUMMYAUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/dummy/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${DUMMYAUDIO_SOURCES})
    set(HAVE_DUMMYAUDIO TRUE)
  endif()
  if(DISKAUDIO)
    set(SDL_AUDIO_DRIVER_DISK 1)
    # file(GLOB DISKAUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/disk/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${DISKAUDIO_SOURCES})
    set(HAVE_DISKAUDIO TRUE)
  endif()
endif()

if(${CMAKE_PROJECT_NAME}_DLOPEN)
  # Relevant for Unix/Darwin only
  if(UNIX OR APPLE)
    CheckDLOPEN()
  endif()
endif()

if(SDL_VIDEO)
  if(VIDEO_DUMMY)
    set(SDL_VIDEO_DRIVER_DUMMY 1)
    # file(GLOB VIDEO_DUMMY_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/dummy/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${VIDEO_DUMMY_SOURCES})
    set(HAVE_VIDEO_DUMMY TRUE)
    set(HAVE_SDL_VIDEO TRUE)
  endif()
endif()

if(ANDROID)
  # file(GLOB ANDROID_CORE_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/core/android/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${ANDROID_CORE_SOURCES})

  # SDL_spinlock.c Needs to be compiled in ARM mode.
  # There seems to be no better way currently to set the ARM mode.
  # see: https://issuetracker.google.com/issues/62264618
  # Another option would be to set ARM mode to all compiled files
  check_c_compiler_flag(-marm HAVE_ARM_MODE)
  if(HAVE_ARM_MODE)
    # set_source_files_properties(${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/atomic/SDL_spinlock.c PROPERTIES COMPILE_FLAGS -marm)
  endif()

  # file(GLOB ANDROID_MAIN_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/main/android/*.c)
  set(SDLMAIN_SOURCES ${SDLMAIN_SOURCES} ${ANDROID_MAIN_SOURCES})

  if(SDL_AUDIO)
    set(SDL_AUDIO_DRIVER_ANDROID 1)
    # file(GLOB ANDROID_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/android/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${ANDROID_AUDIO_SOURCES})
    set(HAVE_SDL_AUDIO TRUE)
  endif()
  if(SDL_FILESYSTEM)
    set(SDL_FILESYSTEM_ANDROID 1)
    # file(GLOB ANDROID_FILESYSTEM_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/filesystem/android/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${ANDROID_FILESYSTEM_SOURCES})
    set(HAVE_SDL_FILESYSTEM TRUE)
  endif()
  if(SDL_HAPTIC)
    set(SDL_HAPTIC_ANDROID 1)
    # file(GLOB ANDROID_HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/android/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${ANDROID_HAPTIC_SOURCES})
    set(HAVE_SDL_HAPTIC TRUE)
  endif()
  if(SDL_JOYSTICK)
    set(SDL_JOYSTICK_ANDROID 1)
    # file(GLOB ANDROID_JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/android/*.c ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/steam/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${ANDROID_JOYSTICK_SOURCES})
    set(HAVE_SDL_JOYSTICK TRUE)
  endif()
  if(SDL_LOADSO)
    set(SDL_LOADSO_DLOPEN 1)
    # file(GLOB LOADSO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/loadso/dlopen/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${LOADSO_SOURCES})
    set(HAVE_SDL_LOADSO TRUE)
  endif()
  if(SDL_POWER)
    set(SDL_POWER_ANDROID 1)
    # file(GLOB ANDROID_POWER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/power/android/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${ANDROID_POWER_SOURCES})
    set(HAVE_SDL_POWER TRUE)
  endif()
  if(SDL_TIMERS)
    set(SDL_TIMER_UNIX 1)
    # file(GLOB TIMER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/timer/unix/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${TIMER_SOURCES})
    set(HAVE_SDL_TIMERS TRUE)
  endif()
  if(SDL_VIDEO)
    set(SDL_VIDEO_DRIVER_ANDROID 1)
    # file(GLOB ANDROID_VIDEO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/android/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${ANDROID_VIDEO_SOURCES})
    set(HAVE_SDL_VIDEO TRUE)

    # Core stuff
    find_library(ANDROID_DL_LIBRARY dl)
    find_library(ANDROID_LOG_LIBRARY log)
    find_library(ANDROID_LIBRARY_LIBRARY android)
    list(APPEND EXTRA_LIBS ${ANDROID_DL_LIBRARY} ${ANDROID_LOG_LIBRARY} ${ANDROID_LIBRARY_LIBRARY})
    list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS GL_GLEXT_PROTOTYPES)

    #enable gles
    if(VIDEO_OPENGLES)
      set(SDL_VIDEO_OPENGL_EGL 1)
      set(HAVE_VIDEO_OPENGLES TRUE)
      set(SDL_VIDEO_OPENGL_ES2 1)
      set(SDL_VIDEO_RENDER_OGL_ES2 1)

      find_library(OpenGLES1_LIBRARY GLESv1_CM)
      find_library(OpenGLES2_LIBRARY GLESv2)
      list(APPEND EXTRA_LIBS ${OpenGLES1_LIBRARY} ${OpenGLES2_LIBRARY})
    endif()

    CHECK_C_SOURCE_COMPILES("
    #if defined(__ARM_ARCH) && __ARM_ARCH < 7
    #error Vulkan doesn't work on this configuration
    #endif
    int main()
    {
        return 0;
    }
    " VULKAN_PASSED_ANDROID_CHECKS)
    if(NOT VULKAN_PASSED_ANDROID_CHECKS)
      set(VIDEO_VULKAN OFF)
      message(STATUS "Vulkan doesn't work on this configuration")
    endif()
  endif()

  CheckPTHREAD()

endif()

include("${${CMAKE_PROJECT_NAME}_REPO_DIRECTORY}/cmake/resources.cmake")

# Platform-specific options and settings
if(EMSCRIPTEN)
  SET(CMAKE_EXECUTABLE_SUFFIX ".html")

  # Hide noisy warnings that intend to aid mostly during initial stages of porting a new
  # project. Uncomment at will for verbose cross-compiling -I/../ path info.
  # add_definitions(-Wno-warn-absolute-paths)
  list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS -Wno-warn-absolute-paths)
  if(SDL_AUDIO)
    set(SDL_AUDIO_DRIVER_EMSCRIPTEN 1)
    # file(GLOB EM_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/emscripten/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${EM_AUDIO_SOURCES})
    set(HAVE_SDL_AUDIO TRUE)
  endif()
  if(SDL_FILESYSTEM)
    set(SDL_FILESYSTEM_EMSCRIPTEN 1)
    # file(GLOB EM_FILESYSTEM_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/filesystem/emscripten/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${EM_FILESYSTEM_SOURCES})
    set(HAVE_SDL_FILESYSTEM TRUE)
  endif()
  if(SDL_JOYSTICK)
    set(SDL_JOYSTICK_EMSCRIPTEN 1)
    # file(GLOB EM_JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/emscripten/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${EM_JOYSTICK_SOURCES})
    set(HAVE_SDL_JOYSTICK TRUE)
  endif()
  if(SDL_POWER)
    set(SDL_POWER_EMSCRIPTEN 1)
    # file(GLOB EM_POWER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/power/emscripten/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${EM_POWER_SOURCES})
    set(HAVE_SDL_POWER TRUE)
  endif()
  if(SDL_TIMERS)
    set(SDL_TIMER_UNIX 1)
    # file(GLOB TIMER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/timer/unix/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${TIMER_SOURCES})
    set(HAVE_SDL_TIMERS TRUE)

    if(CLOCK_GETTIME)
      set(HAVE_CLOCK_GETTIME 1)
    endif()
  endif()
  if(SDL_VIDEO)
    set(SDL_VIDEO_DRIVER_EMSCRIPTEN 1)
    # file(GLOB EM_VIDEO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/emscripten/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${EM_VIDEO_SOURCES})
    set(HAVE_SDL_VIDEO TRUE)

    #enable gles
    if(VIDEO_OPENGLES)
      set(SDL_VIDEO_OPENGL_EGL 1)
      set(HAVE_VIDEO_OPENGLES TRUE)
      set(SDL_VIDEO_OPENGL_ES2 1)
      set(SDL_VIDEO_RENDER_OGL_ES2 1)
    endif()
  endif()
elseif(UNIX AND NOT APPLE AND NOT ANDROID)
  if(SDL_AUDIO)
    if(SYSV5 OR SOLARIS OR HPUX)
        set(SDL_AUDIO_DRIVER_SUNAUDIO 1)
        # file(GLOB SUN_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/sun/*.c)
        # set(SOURCE_FILES ${SOURCE_FILES} ${SUN_AUDIO_SOURCES})
        set(HAVE_SDL_AUDIO TRUE)
    elseif(NETBSD)
        set(SDL_AUDIO_DRIVER_NETBSD 1)
        # file(GLOB NETBSD_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/netbsd/*.c)
        # set(SOURCE_FILES ${SOURCE_FILES} ${NETBSD_AUDIO_SOURCES})
        set(HAVE_SDL_AUDIO TRUE)
    elseif(AIX)
        set(SDL_AUDIO_DRIVER_PAUDIO 1)
        # file(GLOB AIX_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/paudio/*.c)
        # set(SOURCE_FILES ${SOURCE_FILES} ${AIX_AUDIO_SOURCES})
        set(HAVE_SDL_AUDIO TRUE)
    endif()
    CheckOSS()
    CheckALSA()
    CheckJACK()
    CheckPulseAudio()
    CheckESD()
    CheckARTS()
    CheckNAS()
    CheckSNDIO()
    CheckFusionSound()
    CheckLibSampleRate()
  endif()

  if(SDL_VIDEO)
    # Need to check for Raspberry PI first and add platform specific compiler flags, otherwise the test for GLES fails!
    CheckRPI()
    CheckX11()
    CheckMir()
    CheckDirectFB()
    CheckOpenGLX11()
    CheckOpenGLESX11()
    CheckWayland()
    CheckVivante()
    CheckKMSDRM()
  endif()

  if(UNIX)
    # file(GLOB CORE_UNIX_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/core/unix/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${CORE_UNIX_SOURCES})
  endif()

  if(LINUX)
    if(OCULUS)
      list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS OVR_OS_LINUX)
    endif()

    list(APPEND EXTRA_LDFLAGS "-ldl")
    list(APPEND EXTRA_LDFLAGS "-lsndio")

    check_c_source_compiles("
        #include <linux/input.h>
        #ifndef EVIOCGNAME
        #error EVIOCGNAME() ioctl not available
        #endif
        int main(int argc, char** argv) {}" HAVE_INPUT_EVENTS)

    check_c_source_compiles("
        #include <linux/kd.h>
        #include <linux/keyboard.h>

        int main(int argc, char **argv) 
        {
            struct kbentry kbe;
            kbe.kb_table = KG_CTRL;
            ioctl(0, KDGKBENT, &kbe);
        }" HAVE_INPUT_KD)

        # file(GLOB CORE_LINUX_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/core/linux/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${CORE_LINUX_SOURCES})

    if(HAVE_INPUT_EVENTS)
      set(SDL_INPUT_LINUXEV 1)
    endif()

    if(SDL_HAPTIC AND HAVE_INPUT_EVENTS)
      set(SDL_HAPTIC_LINUX 1)
      # file(GLOB HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/linux/*.c)
      # set(SOURCE_FILES ${SOURCE_FILES} ${HAPTIC_SOURCES})
      set(HAVE_SDL_HAPTIC TRUE)
    endif()

    if(HAVE_INPUT_KD)
      set(SDL_INPUT_LINUXKD 1)
    endif()

    check_include_file("libudev.h" HAVE_LIBUDEV_H)

    if(PKG_CONFIG_FOUND)
      pkg_search_module(DBUS dbus-1 dbus)
      if(DBUS_FOUND)
        set(HAVE_DBUS_DBUS_H TRUE)
        include_directories(${DBUS_INCLUDE_DIRS})
        list(APPEND EXTRA_LIBS ${DBUS_LIBRARIES})
      endif()

      pkg_search_module(IBUS ibus-1.0 ibus)
      if(IBUS_FOUND)
        set(HAVE_IBUS_IBUS_H TRUE)
        include_directories(${IBUS_INCLUDE_DIRS})
        list(APPEND EXTRA_LIBS ${IBUS_LIBRARIES})
      endif()
    endif()

    check_include_file("fcitx/frontend.h" HAVE_FCITX_FRONTEND_H)
  endif()

  if(INPUT_TSLIB)
    check_c_source_compiles("
        #include \"tslib.h\"
        int main(int argc, char** argv) { }" HAVE_INPUT_TSLIB)
    if(HAVE_INPUT_TSLIB)
      set(SDL_INPUT_TSLIB 1)
      list(APPEND EXTRA_LIBS ts)
    endif()
  endif()

  if(SDL_JOYSTICK)
    CheckUSBHID()   # seems to be BSD specific - limit the test to BSD only?
    if(LINUX AND NOT ANDROID)
      set(SDL_JOYSTICK_LINUX 1)
      # file(GLOB JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/linux/*.c ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/steam/*.c)
      # set(SOURCE_FILES ${SOURCE_FILES} ${JOYSTICK_SOURCES})
      set(HAVE_SDL_JOYSTICK TRUE)
    endif()
  endif()

  CheckPTHREAD()

  if(CLOCK_GETTIME)
    check_library_exists(rt clock_gettime "" FOUND_CLOCK_GETTIME)
    if(FOUND_CLOCK_GETTIME)
      list(APPEND EXTRA_LIBS rt)
      set(HAVE_CLOCK_GETTIME 1)
    else()
      check_library_exists(c clock_gettime "" FOUND_CLOCK_GETTIME)
      if(FOUND_CLOCK_GETTIME)
        set(HAVE_CLOCK_GETTIME 1)
      endif()
    endif()
  endif()

  check_include_file(linux/version.h HAVE_LINUX_VERSION_H)
  if(HAVE_LINUX_VERSION_H)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DHAVE_LINUX_VERSION_H")
  endif()

  if(SDL_POWER)
    if(LINUX)
      set(SDL_POWER_LINUX 1)
      # file(GLOB POWER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/power/linux/*.c)
      # set(SOURCE_FILES ${SOURCE_FILES} ${POWER_SOURCES})
      set(HAVE_SDL_POWER TRUE)
    endif()
  endif()

  if(SDL_FILESYSTEM)
    set(SDL_FILESYSTEM_UNIX 1)
    # file(GLOB FILESYSTEM_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/filesystem/unix/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${FILESYSTEM_SOURCES})
    set(HAVE_SDL_FILESYSTEM TRUE)
  endif()

  if(SDL_TIMERS)
    set(SDL_TIMER_UNIX 1)
    # file(GLOB TIMER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/timer/unix/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${TIMER_SOURCES})
    set(HAVE_SDL_TIMERS TRUE)
  endif()

  if(RPATH)
    set(SDL_RLD_FLAGS "")
    if(BSDI OR FREEBSD OR LINUX OR NETBSD)
      set(CMAKE_REQUIRED_FLAGS "-Wl,--enable-new-dtags")
      check_c_compiler_flag("" HAVE_ENABLE_NEW_DTAGS)
      set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
      if(HAVE_ENABLE_NEW_DTAGS)
        set(SDL_RLD_FLAGS "-Wl,-rpath,\${libdir} -Wl,--enable-new-dtags")
      else()
        set(SDL_RLD_FLAGS "-Wl,-rpath,\${libdir}")
      endif()
    elseif(SOLARIS)
      set(SDL_RLD_FLAGS "-R\${libdir}")
    endif()
    set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set(HAVE_RPATH TRUE)
  endif()

elseif(WINDOWS)
  if(OCULUS)
    list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS OVR_OS_WIN32)
  endif()

  configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/windows/resource.rc.in"
    "${CMAKEIN_REPO_DIRECTORY}/platform.in/windows/resource.rc")

  set( ASSET_CATALOGUE "${CMAKEIN_REPO_DIRECTORY}/platform.in/windows/resource.rc" )
  list(APPEND RESOURCE_FILES ${ASSET_CATALOGUE})

  find_program(WINDRES windres)

  check_c_source_compiles("
    #include <windows.h>
    int main(int argc, char **argv) { }" HAVE_WIN32_CC)

    # file(GLOB CORE_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/core/windows/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${CORE_SOURCES})

  if(MSVC)
    # Prevent codegen that would use the VC runtime libraries.
    set_property(DIRECTORY . APPEND PROPERTY COMPILE_OPTIONS "/GS-")
    if(NOT ARCH_64)
      set_property(DIRECTORY . APPEND PROPERTY COMPILE_OPTIONS "/arch:SSE")
    endif()
  endif()

  # Check for DirectX
  if(DIRECTX)
    if(DEFINED MSVC_VERSION AND NOT ${MSVC_VERSION} LESS 1700)
        set(USE_WINSDK_DIRECTX TRUE)
    endif()
    if(NOT CMAKE_COMPILER_IS_MINGW AND NOT USE_WINSDK_DIRECTX)
      if("$ENV{DXSDK_DIR}" STREQUAL "")
        message_error("DIRECTX requires the \$DXSDK_DIR environment variable to be set")
      endif()
      set(CMAKE_REQUIRED_FLAGS "/I\"$ENV{DXSDK_DIR}\\Include\"")
    endif()

    if(HAVE_WIN32_CC)
      # xinput.h may need windows.h, but doesn't include it itself.
      check_c_source_compiles("
        #include <windows.h>
        #include <xinput.h>
        int main(int argc, char **argv) { }" HAVE_XINPUT_H)
      check_c_source_compiles("
        #include <windows.h>
        #include <xinput.h>
        XINPUT_GAMEPAD_EX x1;
        int main(int argc, char **argv) { }" HAVE_XINPUT_GAMEPAD_EX)
      check_c_source_compiles("
        #include <windows.h>
        #include <xinput.h>
        XINPUT_STATE_EX s1;
        int main(int argc, char **argv) { }" HAVE_XINPUT_STATE_EX)
    else()
      check_include_file(xinput.h HAVE_XINPUT_H)
    endif()

    check_include_file(d3d9.h HAVE_D3D_H)
    check_include_file(d3d11_1.h HAVE_D3D11_H)
    check_include_file(ddraw.h HAVE_DDRAW_H)
    check_include_file(dsound.h HAVE_DSOUND_H)
    check_include_file(dinput.h HAVE_DINPUT_H)
    check_include_file(xaudio2.h HAVE_XAUDIO2_H)
    check_include_file(mmdeviceapi.h HAVE_MMDEVICEAPI_H)
    check_include_file(audioclient.h HAVE_AUDIOCLIENT_H)
    check_include_file(dxgi.h HAVE_DXGI_H)
    if(HAVE_D3D_H OR HAVE_D3D11_H OR HAVE_DDRAW_H OR HAVE_DSOUND_H OR HAVE_DINPUT_H OR HAVE_XAUDIO2_H)
      set(HAVE_DIRECTX TRUE)
      if(NOT CMAKE_COMPILER_IS_MINGW AND NOT USE_WINSDK_DIRECTX)
      # TODO: change $ENV{DXSDL_DIR} to get the path from the include checks
        link_directories($ENV{DXSDK_DIR}\\lib\\${PROCESSOR_ARCH})
        include_directories($ENV{DXSDK_DIR}\\Include)
      endif()
    endif()
    set(CMAKE_REQUIRED_FLAGS ${ORIG_CMAKE_REQUIRED_FLAGS})
  endif()

  if(SDL_AUDIO)
    set(SDL_AUDIO_DRIVER_WINMM 1)
    # file(GLOB WINMM_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/winmm/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${WINMM_AUDIO_SOURCES})
    set(HAVE_SDL_AUDIO TRUE)

    if(HAVE_DSOUND_H)
      set(SDL_AUDIO_DRIVER_DSOUND 1)
      # file(GLOB DSOUND_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/directsound/*.c)
      # set(SOURCE_FILES ${SOURCE_FILES} ${DSOUND_AUDIO_SOURCES})
    endif()

    if(HAVE_XAUDIO2_H)
      set(SDL_AUDIO_DRIVER_XAUDIO2 1)
      # file(GLOB XAUDIO2_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/xaudio2/*.c)
      # set(SOURCE_FILES ${SOURCE_FILES} ${XAUDIO2_AUDIO_SOURCES})
    endif()

    if(HAVE_AUDIOCLIENT_H AND HAVE_MMDEVICEAPI_H)
      set(SDL_AUDIO_DRIVER_WASAPI 1)
      # file(GLOB WASAPI_AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/wasapi/*.c)
      # set(SOURCE_FILES ${SOURCE_FILES} ${WASAPI_AUDIO_SOURCES})
    endif()
  endif()

  if(SDL_VIDEO)
    # requires SDL_LOADSO on Windows (IME, DX, etc.)
    if(NOT SDL_LOADSO)
      message_error("SDL_VIDEO requires SDL_LOADSO, which is not enabled")
    endif()
    set(SDL_VIDEO_DRIVER_WINDOWS 1)
    # file(GLOB WIN_VIDEO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/windows/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${WIN_VIDEO_SOURCES})

    if(RENDER_D3D AND HAVE_D3D_H)
      set(SDL_VIDEO_RENDER_D3D 1)
      set(HAVE_RENDER_D3D TRUE)
    endif()
    if(RENDER_D3D AND HAVE_D3D11_H)
      set(SDL_VIDEO_RENDER_D3D11 1)
      set(HAVE_RENDER_D3D TRUE)
    endif()
    set(HAVE_SDL_VIDEO TRUE)
  endif()

  if(SDL_THREADS)
    set(SDL_THREAD_WINDOWS 1)
    # set(SOURCE_FILES ${SOURCE_FILES}
    #  ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/thread/windows/SDL_sysmutex.c
    #  ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/thread/windows/SDL_syssem.c
    #  ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/thread/windows/SDL_systhread.c
    #  ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/thread/windows/SDL_systls.c
    #  ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/thread/generic/SDL_syscond.c)
    set(HAVE_SDL_THREADS TRUE)
  endif()

  if(SDL_POWER)
    set(SDL_POWER_WINDOWS 1)
    # set(SOURCE_FILES ${SOURCE_FILES} ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/power/windows/SDL_syspower.c)
    set(HAVE_SDL_POWER TRUE)
  endif()

  if(SDL_FILESYSTEM)
    set(SDL_FILESYSTEM_WINDOWS 1)
    # file(GLOB FILESYSTEM_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/filesystem/windows/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${FILESYSTEM_SOURCES})
    set(HAVE_SDL_FILESYSTEM TRUE)
  endif()

  # Libraries for Win32 native and MinGW
  list(APPEND EXTRA_LIBS user32 gdi32 winmm imm32 ole32 oleaut32 version uuid)

  # TODO: in configure.in the check for timers is set on
  # cygwin | mingw32* - does this include mingw32CE?
  if(SDL_TIMERS)
    set(SDL_TIMER_WINDOWS 1)
    # file(GLOB TIMER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/timer/windows/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${TIMER_SOURCES})
    set(HAVE_SDL_TIMERS TRUE)
  endif()

  if(SDL_LOADSO)
    set(SDL_LOADSO_WINDOWS 1)
    # file(GLOB LOADSO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/loadso/windows/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${LOADSO_SOURCES})
    set(HAVE_SDL_LOADSO TRUE)
  endif()

  # file(GLOB CORE_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/core/windows/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${CORE_SOURCES})

  if(SDL_VIDEO)
    if(VIDEO_OPENGL)
      set(SDL_VIDEO_OPENGL 1)
      set(SDL_VIDEO_OPENGL_WGL 1)
      set(SDL_VIDEO_RENDER_OGL 1)
      set(HAVE_VIDEO_OPENGL TRUE)
    endif()

    if(VIDEO_OPENGLES)
      set(SDL_VIDEO_OPENGL_EGL 1)
      set(SDL_VIDEO_OPENGL_ES2 1)
      set(SDL_VIDEO_RENDER_OGL_ES2 1)
      set(HAVE_VIDEO_OPENGLES TRUE)
    endif()
  endif()

  if(SDL_JOYSTICK)
    # file(GLOB JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/windows/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${JOYSTICK_SOURCES})
    if(HAVE_DINPUT_H)
      set(SDL_JOYSTICK_DINPUT 1)
      list(APPEND EXTRA_LIBS dinput8)
      if(CMAKE_COMPILER_IS_MINGW)
        list(APPEND EXTRA_LIBS dxerr8)
      elseif (NOT USE_WINSDK_DIRECTX)
        list(APPEND EXTRA_LIBS dxerr)
      endif()
    endif()
    if(HAVE_XINPUT_H)
      set(SDL_JOYSTICK_XINPUT 1)
    endif()
    if(NOT HAVE_DINPUT_H AND NOT HAVE_XINPUT_H)
      set(SDL_JOYSTICK_WINMM 1)
    endif()
    set(HAVE_SDL_JOYSTICK TRUE)

    if(SDL_HAPTIC)
      if(HAVE_DINPUT_H OR HAVE_XINPUT_H)
        # file(GLOB HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/windows/*.c)
        if(HAVE_DINPUT_H)
          set(SDL_HAPTIC_DINPUT 1)
        endif()
        if(HAVE_XINPUT_H)
          set(SDL_HAPTIC_XINPUT 1)
        endif()
      else()
        # file(GLOB HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/dummy/*.c)
        set(SDL_HAPTIC_DUMMY 1)
      endif()
      # set(SOURCE_FILES ${SOURCE_FILES} ${HAPTIC_SOURCES})
      set(HAVE_SDL_HAPTIC TRUE)
    endif()
  endif()

  # file(GLOB VERSION_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/main/windows/*.rc)
  # file(GLOB SDLMAIN_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/main/windows/*.c)
  if(MINGW OR CYGWIN)
    list(APPEND EXTRA_LIBS mingw32)
    list(APPEND EXTRA_LDFLAGS "-mwindows")
    set(${CMAKE_PROJECT_NAME}_CFLAGS "${${CMAKE_PROJECT_NAME}_CFLAGS} -Dmain=SDL_main")
    list(APPEND ${CMAKE_PROJECT_NAME}_LIBS "-lmingw32" "-lSDL2main" "-mwindows")
  endif()
elseif(APPLE)
  if(OCULUS)
    list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS OVR_OS_MAC)
  endif()

  # TODO: rework this all for proper MacOS X, iOS and Darwin support

  # We always need these libs on macOS at the moment.
  # !!! FIXME: we need Carbon for some very old API calls in
  # !!! FIXME:  src/video/cocoa/SDL_cocoakeyboard.c, but we should figure out
  # !!! FIXME:  how to dump those.
  if(NOT (IOS OR TVOS))
    SET( ASSET_CATALOGUE "${CMAKEIN_REPO_DIRECTORY}/platform.in/macOS/Assets.xcassets" )
    list(APPEND RESOURCE_FILES ${ASSET_CATALOGUE})
    set(SDL_FRAMEWORK_COCOA 1)
    set(SDL_FRAMEWORK_CARBON 1)
  else()
    if(IOS)
      SET( ASSET_CATALOGUE "${CMAKEIN_REPO_DIRECTORY}/platform.in/ios/Assets.xcassets" )
      list(APPEND RESOURCE_FILES ${ASSET_CATALOGUE})

      SET( CMAKE_OSX_SYSROOT "iphoneos" )
      SET( CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator" )
      SET ( CMAKE_OSX_ARCHITECTURES $(ARCHS_UNIVERSAL_IPHONE_OS) CACHE string "Build architecture for iOS" )

      list(APPEND EXTRA_LIBS "-framework OpenGLES")
      list(APPEND EXTRA_LIBS "-framework UIKit")
      list(APPEND EXTRA_LIBS "-framework Foundation")
      list(APPEND EXTRA_LIBS "-framework AVFoundation")
      list(APPEND EXTRA_LIBS "-framework GameController")
      list(APPEND EXTRA_LIBS "-framework CoreMotion")
      list(APPEND EXTRA_LIBS "-framework CoreGraphics")
      list(APPEND EXTRA_LIBS "-framework QuartzCore")

      list(APPEND EXTRA_LIBS "-framework Metal")

    endif(IOS)
    
    if(TVOS)
      SET( ASSET_CATALOGUE "${CMAKEIN_REPO_DIRECTORY}/platform.in/appletv/Assets.xcassets" )
      list(APPEND RESOURCE_FILES ${ASSET_CATALOGUE})
      SET( CMAKE_OSX_SYSROOT "appletvos" )
      SET( CMAKE_XCODE_EFFECTIVE_PLATFORMS "-appletvos;-appletvsimulator" )
      SET ( CMAKE_OSX_ARCHITECTURES $(ARCHS_UNIVERSAL_APPLETV_OS) CACHE string "Build architecture for appletv" )

      list(APPEND EXTRA_LIBS "-framework OpenGLES")
      list(APPEND EXTRA_LIBS "-framework UIKit")
      list(APPEND EXTRA_LIBS "-framework Foundation")
      list(APPEND EXTRA_LIBS "-framework AVFoundation")
      list(APPEND EXTRA_LIBS "-framework GameController")
      list(APPEND EXTRA_LIBS "-framework CoreGraphics")
      list(APPEND EXTRA_LIBS "-framework QuartzCore")
    endif(TVOS)
  endif()

  # Requires the darwin file implementation
  if(SDL_FILE)
    # file(GLOB EXTRA_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/file/cocoa/*.m)
    # set(SOURCE_FILES ${EXTRA_SOURCES} ${SOURCE_FILES})
    # !!! FIXME: modern CMake doesn't need "LANGUAGE C" for Objective-C.
    set_source_files_properties(${EXTRA_SOURCES} PROPERTIES LANGUAGE C)
    set(HAVE_SDL_FILE TRUE)
    # !!! FIXME: why is COREVIDEO inside this if() block?
    set(SDL_FRAMEWORK_COREVIDEO 1)
  else()
    message_error("SDL_FILE must be enabled to build on MacOS X")
  endif()

  if(SDL_AUDIO)
    set(SDL_AUDIO_DRIVER_COREAUDIO 1)
    # file(GLOB AUDIO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/audio/coreaudio/*.m)
    # !!! FIXME: modern CMake doesn't need "LANGUAGE C" for Objective-C.
    set_source_files_properties(${AUDIO_SOURCES} PROPERTIES LANGUAGE C)
    # set(SOURCE_FILES ${SOURCE_FILES} ${AUDIO_SOURCES})
    set(HAVE_SDL_AUDIO TRUE)
    set(SDL_FRAMEWORK_COREAUDIO 1)
    set(SDL_FRAMEWORK_AUDIOTOOLBOX 1)
  endif()

  if(SDL_JOYSTICK)
    set(SDL_JOYSTICK_IOKIT 1)
    if ((IOS OR TVOS))
      # file(GLOB JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/iphoneos/*.m ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/steam/*.c)
    else()
      # file(GLOB JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/darwin/*.c)
    endif()
    # set(SOURCE_FILES ${SOURCE_FILES} ${JOYSTICK_SOURCES})
    set(HAVE_SDL_JOYSTICK TRUE)
    set(SDL_FRAMEWORK_IOKIT 1)
    set(SDL_FRAMEWORK_FF 1)
  endif()

  if(SDL_HAPTIC)
    set(SDL_HAPTIC_IOKIT 1)
    if ((IOS OR TVOS))
      # file(GLOB HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/dummy/*.c)
      set(SDL_HAPTIC_DUMMY 1)
    else()
      # file(GLOB HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/darwin/*.c)
    endif()
    # set(SOURCE_FILES ${SOURCE_FILES} ${HAPTIC_SOURCES})
    set(HAVE_SDL_HAPTIC TRUE)
    set(SDL_FRAMEWORK_IOKIT 1)
    set(SDL_FRAMEWORK_FF 1)
    if(NOT SDL_JOYSTICK)
      message(FATAL_ERROR "SDL_HAPTIC requires SDL_JOYSTICK to be enabled")
    endif()
  endif()

  if(SDL_POWER)
    set(SDL_POWER_MACOSX 1)
    if ((IOS OR TVOS))
      # file(GLOB POWER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/power/uikit/*.m)
    else()
      # file(GLOB POWER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/power/macosx/*.c)
    endif()
    # set(SOURCE_FILES ${SOURCE_FILES} ${POWER_SOURCES})
    set(HAVE_SDL_POWER TRUE)
    set(SDL_FRAMEWORK_IOKIT 1)
  endif()

  if(SDL_TIMERS)
    set(SDL_TIMER_UNIX 1)
    # file(GLOB TIMER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/timer/unix/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${TIMER_SOURCES})
    set(HAVE_SDL_TIMERS TRUE)
  endif(SDL_TIMERS)

  if(SDL_FILESYSTEM)
    set(SDL_FILESYSTEM_COCOA 1)
    # file(GLOB FILESYSTEM_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/filesystem/cocoa/*.m)
    # !!! FIXME: modern CMake doesn't need "LANGUAGE C" for Objective-C.
    set_source_files_properties(${FILESYSTEM_SOURCES} PROPERTIES LANGUAGE C)
    # set(SOURCE_FILES ${SOURCE_FILES} ${FILESYSTEM_SOURCES})
    set(HAVE_SDL_FILESYSTEM TRUE)
  endif()

  if(IOS OR TVOS)
    set(SDL_FRAMEWORK_FF 0)
    set(SDL_FRAMEWORK_IOKIT 0)
  endif(IOS OR TVOS)

  # Actually load the frameworks at the end so we don't duplicate include.
  if(SDL_FRAMEWORK_COREVIDEO)
    list(APPEND EXTRA_LIBS "-framework CoreVideo")
  endif()
  if(SDL_FRAMEWORK_COCOA)
    list(APPEND EXTRA_LIBS "-framework Cocoa")
  endif()
  if(SDL_FRAMEWORK_IOKIT)
    list(APPEND EXTRA_LIBS "-framework IOKit")
  endif()
  if(SDL_FRAMEWORK_FF)
    list(APPEND EXTRA_LIBS "-framework ForceFeedback")
  endif()
  if(SDL_FRAMEWORK_CARBON)
    list(APPEND EXTRA_LIBS "-framework Carbon")
  endif()
  if(SDL_FRAMEWORK_COREAUDIO)
    list(APPEND EXTRA_LIBS "-framework CoreAudio")
  endif()
  if(SDL_FRAMEWORK_AUDIOTOOLBOX)
    list(APPEND EXTRA_LIBS "-framework AudioToolbox")
  endif()

  # iOS hack needed - http://code.google.com/p/ios-cmake/ ?
  if(SDL_VIDEO)
    if ((IOS OR TVOS))
      set(SDL_VIDEO_DRIVER_UIKIT 1)
      # file(GLOB UIKITVIDEO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/uikit/*.m)
      # set(SOURCE_FILES ${SOURCE_FILES} ${UIKITVIDEO_SOURCES})
    else()
      CheckCOCOA()
      if(VIDEO_OPENGL)
        set(SDL_VIDEO_OPENGL 1)
        set(SDL_VIDEO_OPENGL_CGL 1)
        set(SDL_VIDEO_RENDER_OGL 1)
        set(HAVE_VIDEO_OPENGL TRUE)
      endif()
    endif()
  endif()

  CheckPTHREAD()
elseif(HAIKU)
  if(SDL_VIDEO)
    set(SDL_VIDEO_DRIVER_HAIKU 1)
    # file(GLOB HAIKUVIDEO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/video/haiku/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${HAIKUVIDEO_SOURCES})
    set(HAVE_SDL_VIDEO TRUE)

    set(SDL_FILESYSTEM_HAIKU 1)
    # file(GLOB FILESYSTEM_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/filesystem/haiku/*.cc)
    # set(SOURCE_FILES ${SOURCE_FILES} ${FILESYSTEM_SOURCES})
    set(HAVE_SDL_FILESYSTEM TRUE)

    if(SDL_TIMERS)
      set(SDL_TIMER_HAIKU 1)
      file(GLOB TIMER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/timer/haiku/*.c)
      # set(SOURCE_FILES ${SOURCE_FILES} ${TIMER_SOURCES})
      set(HAVE_SDL_TIMERS TRUE)
    endif(SDL_TIMERS)

    if(VIDEO_OPENGL)
      # TODO: Use FIND_PACKAGE(OpenGL) instead
      set(SDL_VIDEO_OPENGL 1)
      set(SDL_VIDEO_OPENGL_BGL 1)
      set(SDL_VIDEO_RENDER_OGL 1)
      list(APPEND EXTRA_LIBS GL)
      set(HAVE_VIDEO_OPENGL TRUE)
    endif()
  endif()

  CheckPTHREAD()
endif()

if(VIDEO_VULKAN)
  set(SDL_VIDEO_VULKAN 1)
endif()

# Dummies
# configure.in does it differently:
# if not have X
#   if enable_X {  SDL_X_DISABLED = 1 }
#   [add dummy sources]
# so it always adds a dummy, without checking, if it was actually requested.
# This leads to missing internal references on building, since the
# src/X/*.c does not get included.
if(NOT HAVE_SDL_JOYSTICK)
  set(SDL_JOYSTICK_DISABLED 1)
  if(SDL_JOYSTICK AND NOT APPLE) # results in unresolved symbols on OSX

    # file(GLOB JOYSTICK_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/joystick/dummy/*.c)
    # set(SOURCE_FILES ${SOURCE_FILES} ${JOYSTICK_SOURCES})
  endif()
endif()
if(NOT HAVE_SDL_HAPTIC)
  set(SDL_HAPTIC_DISABLED 1)
  # file(GLOB HAPTIC_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/haptic/dummy/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${HAPTIC_SOURCES})
endif()
if(NOT HAVE_SDL_LOADSO)
  set(SDL_LOADSO_DISABLED 1)
  # file(GLOB LOADSO_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/loadso/dummy/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${LOADSO_SOURCES})
endif()
if(NOT HAVE_SDL_FILESYSTEM)
  set(SDL_FILESYSTEM_DISABLED 1)
  # file(GLOB FILESYSTEM_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/filesystem/dummy/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${FILESYSTEM_SOURCES})
endif()

# We always need to have threads and timers around
if(NOT HAVE_SDL_THREADS)
  set(SDL_THREADS_DISABLED 1)
  # file(GLOB THREADS_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/thread/generic/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${THREADS_SOURCES})
endif()
if(NOT HAVE_SDL_TIMERS)
  set(SDL_TIMERS_DISABLED 1)
  # file(GLOB TIMER_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/timer/dummy/*.c)
  # set(SOURCE_FILES ${SOURCE_FILES} ${TIMER_SOURCES})
endif()

if(NOT SDLMAIN_SOURCES)
  # file(GLOB SDLMAIN_SOURCES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/src/main/dummy/*.c)
endif()

# Append the -MMD -MT flags
# if(DEPENDENCY_TRACKING)
#   if(COMPILER_IS_GNUCC)
#     set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -MMD -MT \$@")
#   endif()
# endif()

configure_file("${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/SDL_config.h.cmake"
  "${${CMAKE_PROJECT_NAME}_BINARY_DIR}/SDL_config.h")

# Prepare the flags and remove duplicates
if(EXTRA_LDFLAGS)
  list(REMOVE_DUPLICATES EXTRA_LDFLAGS)
endif()
if(EXTRA_LIBS)
  list(REMOVE_DUPLICATES EXTRA_LIBS)
endif()
if(EXTRA_CFLAGS)
  list(REMOVE_DUPLICATES EXTRA_CFLAGS)
endif()
listtostr(EXTRA_CFLAGS _EXTRA_CFLAGS)
set(EXTRA_CFLAGS ${_EXTRA_CFLAGS})

# Compat helpers for the configuration files
if(NOT WINDOWS OR CYGWIN)
  # TODO: we need a Windows script, too
  execute_process(COMMAND sh ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/build-scripts/updaterev.sh)

  set(prefix ${CMAKE_INSTALL_PREFIX})
  set(exec_prefix "\${prefix}")
  set(libdir "\${exec_prefix}/lib${LIB_SUFFIX}")
  set(bindir "\${exec_prefix}/bin")
  set(includedir "\${prefix}/include")
  if(${CMAKE_PROJECT_NAME}_STATIC)
    set(ENABLE_STATIC_TRUE "")
    set(ENABLE_STATIC_FALSE "#")
  else()
    set(ENABLE_STATIC_TRUE "#")
    set(ENABLE_STATIC_FALSE "")
  endif()
  if(${CMAKE_PROJECT_NAME}_SHARED)
    set(ENABLE_SHARED_TRUE "")
    set(ENABLE_SHARED_FALSE "#")
  else()
    set(ENABLE_SHARED_TRUE "#")
    set(ENABLE_SHARED_FALSE "")
  endif()

  # Clean up the different lists
  listtostr(EXTRA_LIBS _EXTRA_LIBS "-l")
  set(${CMAKE_PROJECT_NAME}_STATIC_LIBS ${${CMAKE_PROJECT_NAME}_LIBS} ${EXTRA_LDFLAGS} ${_EXTRA_LIBS})
  list(REMOVE_DUPLICATES ${CMAKE_PROJECT_NAME}_STATIC_LIBS)
  listtostr(${CMAKE_PROJECT_NAME}_STATIC_LIBS _${CMAKE_PROJECT_NAME}_STATIC_LIBS)
  set(${CMAKE_PROJECT_NAME}_STATIC_LIBS ${_${CMAKE_PROJECT_NAME}_STATIC_LIBS})
  listtostr(${CMAKE_PROJECT_NAME}_LIBS _${CMAKE_PROJECT_NAME}_LIBS)
  set(${CMAKE_PROJECT_NAME}_LIBS ${_${CMAKE_PROJECT_NAME}_LIBS})

  configure_file("${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/njlic.pc.in"
    "${${CMAKE_PROJECT_NAME}_BINARY_DIR}/njlic.pc" @ONLY)
  configure_file("${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/njlic-config.in"
    "${${CMAKE_PROJECT_NAME}_BINARY_DIR}/njlic-config")
  configure_file("${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/njlic-config.in"
    "${${CMAKE_PROJECT_NAME}_BINARY_DIR}/njlic-config" @ONLY)
  configure_file("${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/${CMAKE_PROJECT_NAME}.spec.in"
    "${${CMAKE_PROJECT_NAME}_BINARY_DIR}/${CMAKE_PROJECT_NAME}.spec" @ONLY)
endif()

set( EXTRA_DEBUG_LIBS "" )
include("${CMAKE_SOURCE_DIR}/cmake/external_libraries.cmake")
include("${${CMAKE_PROJECT_NAME}_REPO_DIRECTORY}/cmake/external_libraries.cmake")

##### Info output #####
message(STATUS "")
message(STATUS "${CMAKE_PROJECT_NAME} was configured with the following options:")
message(STATUS "")
message(STATUS "Platform: ${CMAKE_SYSTEM}")
message(STATUS "64-bit:   ${ARCH_64}")
message(STATUS "Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "")
message(STATUS "Subsystems:")
foreach(_SUB ${SDL_SUBSYSTEMS})
  string(TOUPPER ${_SUB} _OPT)
  message_bool_option(${_SUB} SDL_${_OPT})
endforeach()
message(STATUS "")
message(STATUS "Options:")
list(SORT ALLOPTIONS)
foreach(_OPT ${ALLOPTIONS})
  # Longest option is VIDEO_X11_XSCREENSAVER = 22 characters
  # Get the padding
  string(LENGTH ${_OPT} _OPTLEN)
  math(EXPR _PADLEN "23 - ${_OPTLEN}")
  string(RANDOM LENGTH ${_PADLEN} ALPHABET " " _PADDING)
  message_tested_option(${_OPT} ${_PADDING})
endforeach()
message(STATUS "")
message(STATUS " CFLAGS:        ${CMAKE_C_FLAGS}")
message(STATUS " CXXFLAGS:      ${CMAKE_CXX_FLAGS}")
message(STATUS " EXTRA_CFLAGS:  ${EXTRA_CFLAGS}")
message(STATUS " EXTRA_LDFLAGS: ${EXTRA_LDFLAGS}")
message(STATUS " EXTRA_LIBS:    ${EXTRA_LIBS}")
message(STATUS "")
message(STATUS " Build Shared Library: ${${CMAKE_PROJECT_NAME}_SHARED}")
message(STATUS " Build Static Library: ${${CMAKE_PROJECT_NAME}_STATIC}")
message(STATUS " Build Executable: ${${CMAKE_PROJECT_NAME}_EXE}")
if(${CMAKE_PROJECT_NAME}_STATIC)
    message(STATUS " Build Static Library with Position Independent Code: ${${CMAKE_PROJECT_NAME}_STATIC_PIC}")
endif()
message(STATUS "")
if(UNIX)
  message(STATUS "If something was not detected, although the libraries")
  message(STATUS "were installed, then make sure you have set the")
  message(STATUS "CFLAGS and LDFLAGS environment variables correctly.")
  message(STATUS "")
endif()

# ------------------------- Begin Generic CMake Variable Logging ------------------

# /*	C++ comment style not allowed	*/

MESSAGE( STATUS "CMAKE_GENERATOR:         " ${CMAKE_GENERATOR} )

# if you are building in-source, this is the same as CMAKE_SOURCE_DIR, otherwise
# this is the top level directory of your build tree
MESSAGE( STATUS "CMAKE_BINARY_DIR:         " ${CMAKE_BINARY_DIR} )

# if you are building in-source, this is the same as CMAKE_CURRENT_SOURCE_DIR, otherwise this
# is the directory where the compiled or generated files from the current CMakeLists.txt will go to
MESSAGE( STATUS "CMAKE_CURRENT_BINARY_DIR: " ${CMAKE_CURRENT_BINARY_DIR} )

# this is the directory, from which cmake was started, i.e. the top level source directory
MESSAGE( STATUS "CMAKE_SOURCE_DIR:         " ${CMAKE_SOURCE_DIR} )

# this is the directory where the currently processed CMakeLists.txt is located in
MESSAGE( STATUS "CMAKE_CURRENT_SOURCE_DIR: " ${CMAKE_CURRENT_SOURCE_DIR} )

# contains the full path to the top level directory of your build tree
MESSAGE( STATUS "PROJECT_BINARY_DIR: " ${PROJECT_BINARY_DIR} )

# contains the full path to the root of your project source directory,
# i.e. to the nearest directory where CMakeLists.txt contains the PROJECT() command
MESSAGE( STATUS "PROJECT_SOURCE_DIR: " ${PROJECT_SOURCE_DIR} )

# set this variable to specify a common place where CMake should put all executable files
# (instead of CMAKE_CURRENT_BINARY_DIR)
MESSAGE( STATUS "EXECUTABLE_OUTPUT_PATH: " ${EXECUTABLE_OUTPUT_PATH} )

# set this variable to specify a common place where CMake should put all libraries
# (instead of CMAKE_CURRENT_BINARY_DIR)
MESSAGE( STATUS "LIBRARY_OUTPUT_PATH:     " ${LIBRARY_OUTPUT_PATH} )

# tell CMake to search first in directories listed in CMAKE_MODULE_PATH
# when you use FIND_PACKAGE() or INCLUDE()
MESSAGE( STATUS "CMAKE_MODULE_PATH: " ${CMAKE_MODULE_PATH} )

# this is the complete path of the cmake which runs currently (e.g. /usr/local/bin/cmake)
MESSAGE( STATUS "CMAKE_COMMAND: " ${CMAKE_COMMAND} )

# this is the CMake installation directory
MESSAGE( STATUS "CMAKE_ROOT: " ${CMAKE_ROOT} )

# this is the filename including the complete path of the file where this variable is used.
MESSAGE( STATUS "CMAKE_CURRENT_LIST_FILE: " ${CMAKE_CURRENT_LIST_FILE} )

# this is linenumber where the variable is used
MESSAGE( STATUS "CMAKE_CURRENT_LIST_LINE: " ${CMAKE_CURRENT_LIST_LINE} )

# this is used when searching for include files e.g. using the FIND_PATH() command.
MESSAGE( STATUS "CMAKE_INCLUDE_PATH: " ${CMAKE_INCLUDE_PATH} )

# this is used when searching for libraries e.g. using the FIND_LIBRARY() command.
MESSAGE( STATUS "CMAKE_LIBRARY_PATH: " ${CMAKE_LIBRARY_PATH} )

# the complete system name, e.g. "Linux-2.4.22", "FreeBSD-5.4-RELEASE" or "Windows 5.1"
MESSAGE( STATUS "CMAKE_SYSTEM: " ${CMAKE_SYSTEM} )

# the short system name, e.g. "Linux", "FreeBSD" or "Windows"
MESSAGE( STATUS "CMAKE_SYSTEM_NAME: " ${CMAKE_SYSTEM_NAME} )

# only the version part of CMAKE_SYSTEM
MESSAGE( STATUS "CMAKE_SYSTEM_VERSION: " ${CMAKE_SYSTEM_VERSION} )

# the processor name (e.g. "Intel(R) Pentium(R) M processor 2.00GHz")
MESSAGE( STATUS "CMAKE_SYSTEM_PROCESSOR: " ${CMAKE_SYSTEM_PROCESSOR} )

# is TRUE on all UNIX-like OS's, including Apple OS X and CygWin
MESSAGE( STATUS "UNIX: " ${UNIX} )

# is TRUE on Windows, including CygWin
MESSAGE( STATUS "WIN32: " ${WIN32} )

# is TRUE on Apple OS X
MESSAGE( STATUS "APPLE: " ${APPLE} )

# is TRUE when using the MinGW compiler in Windows
MESSAGE( STATUS "MINGW: " ${MINGW} )

# is TRUE on Windows when using the CygWin version of cmake
MESSAGE( STATUS "CYGWIN: " ${CYGWIN} )

# is TRUE on Windows when using a Borland compiler
MESSAGE( STATUS "BORLAND: " ${BORLAND} )

# Microsoft compiler
MESSAGE( STATUS "MSVC: " ${MSVC} )
MESSAGE( STATUS "MSVC_IDE: " ${MSVC_IDE} )
MESSAGE( STATUS "MSVC60: " ${MSVC60} )
MESSAGE( STATUS "MSVC70: " ${MSVC70} )
MESSAGE( STATUS "MSVC71: " ${MSVC71} )
MESSAGE( STATUS "MSVC80: " ${MSVC80} )
MESSAGE( STATUS "CMAKE_COMPILER_2005: " ${CMAKE_COMPILER_2005} )


# set this to true if you don't want to rebuild the object files if the rules have changed,
# but not the actual source files or headers (e.g. if you changed the some compiler switches)
MESSAGE( STATUS "CMAKE_SKIP_RULE_DEPENDENCY: " ${CMAKE_SKIP_RULE_DEPENDENCY} )

# since CMake 2.1 the install rule depends on all, i.e. everything will be built before installing.
# If you don't like this, set this one to true.
MESSAGE( STATUS "CMAKE_SKIP_INSTALL_ALL_DEPENDENCY: " ${CMAKE_SKIP_INSTALL_ALL_DEPENDENCY} )

# If set, runtime paths are not added when using shared libraries. Default it is set to OFF
MESSAGE( STATUS "CMAKE_SKIP_RPATH: " ${CMAKE_SKIP_RPATH} )

# set this to true if you are using makefiles and want to see the full compile and link
# commands instead of only the shortened ones
MESSAGE( STATUS "CMAKE_VERBOSE_MAKEFILE: " ${CMAKE_VERBOSE_MAKEFILE} )

# this will cause CMake to not put in the rules that re-run CMake. This might be useful if
# you want to use the generated build files on another machine.
MESSAGE( STATUS "CMAKE_SUPPRESS_REGENERATION: " ${CMAKE_SUPPRESS_REGENERATION} )


# A simple way to get switches to the compiler is to use ADD_DEFINITIONS().
# But there are also two variables exactly for this purpose:

# the compiler flags for compiling C sources
MESSAGE( STATUS "CMAKE_C_FLAGS: " ${CMAKE_C_FLAGS} )

# the compiler flags for compiling C++ sources
MESSAGE( STATUS "CMAKE_CXX_FLAGS: " ${CMAKE_CXX_FLAGS} )


# Choose the type of build.  Example: SET(CMAKE_BUILD_TYPE Debug)
MESSAGE( STATUS "CMAKE_BUILD_TYPE: " ${CMAKE_BUILD_TYPE} )

# if this is set to ON, then all libraries are built as shared libraries by default.
MESSAGE( STATUS "BUILD_SHARED_LIBS: " ${BUILD_SHARED_LIBS} )

# the compiler used for C files
MESSAGE( STATUS "CMAKE_C_COMPILER: " ${CMAKE_C_COMPILER} )

# the compiler used for C++ files
MESSAGE( STATUS "CMAKE_CXX_COMPILER: " ${CMAKE_CXX_COMPILER} )

# if the compiler is a variant of gcc, this should be set to 1
MESSAGE( STATUS "CMAKE_COMPILER_IS_GNUCC: " ${CMAKE_COMPILER_IS_GNUCC} )

# if the compiler is a variant of g++, this should be set to 1
MESSAGE( STATUS "CMAKE_COMPILER_IS_GNUCXX : " ${CMAKE_COMPILER_IS_GNUCXX} )

# the tools for creating libraries
MESSAGE( STATUS "CMAKE_AR: " ${CMAKE_AR} )
MESSAGE( STATUS "CMAKE_RANLIB: " ${CMAKE_RANLIB} )

# get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
# MESSAGE(STATUS "INCLUDE_DIRECTORIES='${dirs}'")

#
#MESSAGE( STATUS ": " ${} )

# ------------------------- End of Generic CMake Variable Logging ------------------

# Ensure that the extra cflags are used at compile time
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_CFLAGS}")

# include("${${CMAKE_PROJECT_NAME}_REPO_DIRECTORY}/cmake/source_groups.cmake")

if(${CMAKE_PROJECT_NAME}_SHARED)
  if(ANDROID)

    string(TOLOWER ${CMAKE_BUILD_TYPE} ANDROID_BUILD_DIR)
    set(DISTRIBUTION_DIR ${CMAKE_SOURCE_DIR}/android/distribution/android/SDL2/intermediates/ndkBuild)
    set(SDL_LOCATION ${CMAKE_SOURCE_DIR}/android/thirdparty/SDL2)

    add_library( SDL2 SHARED IMPORTED )
    set_target_properties(SDL2 PROPERTIES IMPORTED_LOCATION ${DISTRIBUTION_DIR}/${ANDROID_BUILD_DIR}/obj/local/${ANDROID_ABI}/libSDL2.so)

    include_directories(${SDL_LOCATION}/SDL2/include)

    add_library( main SHARED ${SDL_LOCATION}/SDL2/src/main/android/SDL_android_main.c ${SOURCE_FILES} ${MAIN_FILES} ${RESOURCE_FILES})
    target_link_libraries( main SDL2 ${EXTRA_LIBS} ${EXTRA_LDFLAGS})
    foreach(EXTRA_DEBUG_LIB ${EXTRA_DEBUG_LIBS})
      target_link_libraries( main debug ${EXTRA_DEBUG_LIB})
    endforeach()

    foreach(dir hdpi ldpi mdpi xhdpi xxhdpi xxxhdpi)
      add_custom_command(TARGET main POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_SOURCE_DIR}/android/app/.externalNativeBuild/cmake/${ANDROID_BUILD_DIR}/${ANDROID_ABI}/cmake.in/platform.in/android/res/mipmap-${dir}"
        "${CMAKE_SOURCE_DIR}/android/app/src/main/res/mipmap-${dir}"
        )
    endforeach(dir)

    configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/android/res/values/generated_strings.xml.in"
      "${CMAKE_SOURCE_DIR}/android/app/.externalNativeBuild/cmake/${ANDROID_BUILD_DIR}/${ANDROID_ABI}/cmake.in/platform.in/android/res/values")


  else()
    LIST(REMOVE_ITEM SOURCE_FILES ${MAIN_FILES})

    add_library(${CMAKE_PROJECT_NAME} SHARED ${SOURCE_FILES} ${VERSION_SOURCES} ${INCLUDE_FILES})
    target_compile_definitions(${CMAKE_PROJECT_NAME} PUBLIC ${${CMAKE_PROJECT_NAME}_DEFINITIONS})

    if(APPLE)
      set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES MACOSX_RPATH 1)
      if(IOS OR TVOS)
        SET_TARGET_PROPERTIES (
          ${CMAKE_PROJECT_NAME} PROPERTIES
          XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
          )
      endif(IOS OR TVOS)
    elseif(UNIX AND NOT ANDROID)
      set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        VERSION ${LT_VERSION}
        SOVERSION ${LT_REVISION}
        OUTPUT_NAME "${CMAKE_PROJECT_NAME}-${LT_RELEASE}")
    else()
      set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
        VERSION ${${CMAKE_PROJECT_NAME}_VERSION}
        SOVERSION ${LT_REVISION}
        OUTPUT_NAME "${CMAKE_PROJECT_NAME}")
    endif()
    if(MSVC AND NOT LIBC)
      # Don't try to link with the default set of libraries.
      # set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS_RELEASE "/NODEFAULTLIB")
      # set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS_DEBUG "/NODEFAULTLIB")
      # set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES STATIC_LIBRARY_FLAGS "/NODEFAULTLIB")
    endif()
    set(_INSTALL_LIBS "${CMAKE_PROJECT_NAME}" ${_INSTALL_LIBS})
    target_include_directories(${CMAKE_PROJECT_NAME}
      PUBLIC $<INSTALL_INTERFACE:include>
      PRIVATE $<BUILD_INTERFACE:${${CMAKE_PROJECT_NAME}_THIRDPARTY_INCLUDE_DIRECTORES}>
      PRIVATE $<BUILD_INTERFACE:${${CMAKE_PROJECT_NAME}_PROJECT_INCLUDE_DIRECTORES}>
      )
    target_link_libraries(${CMAKE_PROJECT_NAME} ${EXTRA_LIBS} ${EXTRA_LDFLAGS})
    foreach(EXTRA_DEBUG_LIB ${EXTRA_DEBUG_LIBS})
      target_link_libraries( ${CMAKE_PROJECT_NAME} debug ${EXTRA_DEBUG_LIB})
    endforeach()
  endif()
endif(${CMAKE_PROJECT_NAME}_SHARED)

if(${CMAKE_PROJECT_NAME}_STATIC)
  LIST(REMOVE_ITEM SOURCE_FILES ${MAIN_FILES})
  set (BUILD_SHARED_LIBS FALSE)
  add_library(${CMAKE_PROJECT_NAME}-static STATIC ${SOURCE_FILES} ${INCLUDE_FILES})
  target_compile_definitions(${CMAKE_PROJECT_NAME}-static PUBLIC ${${CMAKE_PROJECT_NAME}_DEFINITIONS})
  if(APPLE)
    if(IOS OR TVOS)
      SET_TARGET_PROPERTIES (
        ${CMAKE_PROJECT_NAME}-static PROPERTIES
        XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
        )
    endif(IOS OR TVOS)
  endif(APPLE)

  if (NOT ${CMAKE_PROJECT_NAME}_SHARED OR NOT WIN32)
    set_target_properties(${CMAKE_PROJECT_NAME}-static PROPERTIES OUTPUT_NAME "${CMAKE_PROJECT_NAME}")
    # Note: Apparently, OUTPUT_NAME must really be unique; even when
    # CMAKE_IMPORT_LIBRARY_SUFFIX or the like are given. Otherwise
    # the static build may race with the import lib and one will get
    # clobbered, when the suffix is realized via subsequent rename.
  endif()
  set_target_properties(${CMAKE_PROJECT_NAME}-static PROPERTIES POSITION_INDEPENDENT_CODE ${${CMAKE_PROJECT_NAME}_STATIC_PIC})
  if(MSVC AND NOT LIBC)
    set_target_properties(${CMAKE_PROJECT_NAME}-static PROPERTIES LINK_FLAGS_RELEASE "/NODEFAULTLIB")
    set_target_properties(${CMAKE_PROJECT_NAME}-static PROPERTIES LINK_FLAGS_DEBUG "/NODEFAULTLIB")
    set_target_properties(${CMAKE_PROJECT_NAME}-static PROPERTIES STATIC_LIBRARY_FLAGS "/NODEFAULTLIB")
  endif()
  # TODO: Win32 platforms keep the same suffix .lib for import and static
  # libraries - do we need to consider this?
  set(_INSTALL_LIBS "${CMAKE_PROJECT_NAME}-static" ${_INSTALL_LIBS})
  target_include_directories(${CMAKE_PROJECT_NAME}-static 
    PUBLIC $<INSTALL_INTERFACE:include>
    PRIVATE $<BUILD_INTERFACE:${${CMAKE_PROJECT_NAME}_THIRDPARTY_INCLUDE_DIRECTORES}>
    PRIVATE $<BUILD_INTERFACE:${${CMAKE_PROJECT_NAME}_PROJECT_INCLUDE_DIRECTORES}>
    )
  target_link_libraries(${CMAKE_PROJECT_NAME}-static ${EXTRA_LIBS} ${EXTRA_LDFLAGS})
  foreach(EXTRA_DEBUG_LIB ${EXTRA_DEBUG_LIBS})
    target_link_libraries( ${CMAKE_PROJECT_NAME}-static debug ${EXTRA_DEBUG_LIB})
  endforeach()
endif(${CMAKE_PROJECT_NAME}_STATIC)

include("${${CMAKE_PROJECT_NAME}_REPO_DIRECTORY}/cmake/targets.cmake")

SOURCE_GROUP_BY_FOLDER(${${CMAKE_PROJECT_NAME}_REPO_DIRECTORY})

if(${CMAKE_PROJECT_NAME}_EXE)
  add_executable(${CMAKE_PROJECT_NAME}-exe MACOSX_BUNDLE ${SOURCE_FILES} ${MAIN_FILES} ${RESOURCE_FILES} ${INCLUDE_FILES})
  # add_dependencies(${CMAKE_PROJECT_NAME}-exe engine_code)
  SET_TARGET_PROPERTIES(
    ${CMAKE_PROJECT_NAME}-exe PROPERTIES
    RESOURCE "${RESOURCE_FILES}"
    )

  if(EMSCRIPTEN)
    set_target_properties(${CMAKE_PROJECT_NAME}-exe PROPERTIES OUTPUT_NAME "index")
  else()
    set_target_properties(${CMAKE_PROJECT_NAME}-exe PROPERTIES OUTPUT_NAME "${EXECUTABLE_NAME}")
  endif()
  list(APPEND ${CMAKE_PROJECT_NAME}_DEFINITIONS EXECUTABLE_NAME="\\"${EXECUTABLE_NAME}\\"")

  target_compile_definitions(${CMAKE_PROJECT_NAME}-exe PUBLIC ${${CMAKE_PROJECT_NAME}_DEFINITIONS})

  if(APPLE)

    # https://stackoverflow.com/questions/40664125/cmake-and-code-signing-in-xcode-8-for-ios-projects?rq=1
    # Automatic
    # SET_XCODE_PROPERTY(MyTarget CODE_SIGN_IDENTITY "iPhone Developer")
    # SET_XCODE_PROPERTY(MyTarget DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID})

    # Manual
    # SET_XCODE_PROPERTY(MyTarget CODE_SIGN_IDENTITY ${CODESIGNIDENTITY})
    # SET_XCODE_PROPERTY(MyTarget DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID})
    # SET_XCODE_PROPERTY(MyTarget PROVISIONING_PROFILE_SPECIFIER ${PROVISIONING_PROFILE_NAME})
    # 
    # PROVISIONING_PROFILE_NAME - file name without extension eg. My full name: Game_AppStore.mobileprovision so here I write Game_AppStore
    # CODESIGNIDENTITY - Set to your preferred code sign identity, to see list: /usr/bin/env xcrun security find-identity -v -p codesigning

    # This little macro lets you set any XCode specific property
    # macro (set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE)
    #     set_property (TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} ${XCODE_VALUE})
    # endmacro (set_xcode_property)

    SET_SOURCE_FILES_PROPERTIES(
      ${NJLI_RESOURCES}
      PROPERTIES
      MACOSX_PACKAGE_LOCATION ${CMAKE_PROJECT_NAME}-exe/Contents/Resources/
      )

    
    # macOS and iOS and tvOS
    SET_TARGET_PROPERTIES(
      ${CMAKE_PROJECT_NAME}-exe PROPERTIES
      MACOSX_BUNDLE TRUE
      XCODE_ATTRIBUTE_INSTALL_PATH "/Applications"
      XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "SRBQ5SCF5X"
      )

    if(NOT IOS AND NOT TVOS)
      configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/macOS/Info.plist.in"
        "${CMAKE_BINARY_DIR}/Info.plist")

      # macOS
      SET_TARGET_PROPERTIES (
        ${CMAKE_PROJECT_NAME}-exe PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_BINARY_DIR}/Info.plist"
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.njlicgames.engine.macos.source"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Mac Developer"
        )
    else()
      # iOS and tvOS
      SET_TARGET_PROPERTIES(
        ${CMAKE_PROJECT_NAME}-exe PROPERTIES
        RESOURCE "${ASSET_CATALOGUE}"
        XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
        XCODE_ATTRIBUTE_INSTALL_PATH "${CMAKE_BINARY_DIR}/ProductRelease"
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME "LaunchImage"
        XCODE_ATTRIBUTE_PRODUCT_NAME "${CMAKE_PROJECT_NAME}GameEngine"
        XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
        )
    endif(NOT IOS AND NOT TVOS)

    if(IOS)
      configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/ios/Info.plist.in"
        "${CMAKE_BINARY_DIR}/Info.plist")

      SET_TARGET_PROPERTIES (
        ${CMAKE_PROJECT_NAME}-exe PROPERTIES
        XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
        XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES "NO"
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_BINARY_DIR}/Info.plist"
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.njlicgames.engine.ios.source"
        )
    endif(IOS)

    if(TVOS)
      configure_file("${CMAKEIN_REPO_DIRECTORY}/platform.in/appletv/Info.plist.in"
        "${CMAKE_BINARY_DIR}/Info.plist")

      SET_TARGET_PROPERTIES (
        ${CMAKE_PROJECT_NAME}-exe PROPERTIES
        XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "3"
        XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES "NO"
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_BINARY_DIR}/Info.plist"
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "App Icon & Top Shelf Image"
        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.njlicgames.engine.appletv.source"
        )
    endif(TVOS)
  elseif(UNIX AND NOT ANDROID)
  else()
  endif()
  if(MSVC AND NOT LIBC)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${CMAKE_PROJECT_NAME}-exe)

    set(SDL_DYNAMIC_IMPORT_LOCATION "${CMAKE_BINARY_DIR}/${LIBSDL_LIBRARY_TARGET_DIRECTORY}/SDL2.${DYNAMIC_LIBRARY_EXTENSION}")

    add_custom_command(TARGET ${CMAKE_PROJECT_NAME}-exe POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
      ${SDL_DYNAMIC_IMPORT_LOCATION}
      $<TARGET_FILE_DIR:${CMAKE_PROJECT_NAME}-exe>)

    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}-exe.Cpp.user.props" [=[
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
<LocalDebuggerEnvironment>PATH=]=] ${CMAKE_BINARY_DIR}/${LIBSDL_LIBRARY_TARGET_DIRECTORY} [=[ ;$(PATH)</LocalDebuggerEnvironment>
</PropertyGroup>
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
<LocalDebuggerEnvironment>PATH=]=] ${CMAKE_BINARY_DIR}/${LIBSDL_LIBRARY_TARGET_DIRECTORY} [=[ ;$(PATH)</LocalDebuggerEnvironment>
</PropertyGroup>
</Project>
]=])

    set_target_properties(${CMAKE_PROJECT_NAME}-exe PROPERTIES VS_USER_PROPS "${CMAKE_PROJECT_NAME}-exe.Cpp.user.props")

    # Don't try to link with the default set of libraries.
    # set_target_properties(${CMAKE_PROJECT_NAME}-exe PROPERTIES LINK_FLAGS_RELEASE "/NODEFAULTLIB")
    # set_target_properties(${CMAKE_PROJECT_NAME}-exe PROPERTIES LINK_FLAGS_DEBUG "/NODEFAULTLIB")
    # set_target_properties(${CMAKE_PROJECT_NAME}-exe PROPERTIES STATIC_LIBRARY_FLAGS "/NODEFAULTLIB")
  endif()
  target_include_directories(${CMAKE_PROJECT_NAME}-exe
    PRIVATE $<BUILD_INTERFACE:${${CMAKE_PROJECT_NAME}_THIRDPARTY_INCLUDE_DIRECTORES}>
    PRIVATE $<BUILD_INTERFACE:${${CMAKE_PROJECT_NAME}_PROJECT_INCLUDE_DIRECTORES}>
    )
  target_link_libraries(${CMAKE_PROJECT_NAME}-exe ${EXTRA_LIBS} ${EXTRA_LDFLAGS})
  foreach(EXTRA_DEBUG_LIB ${EXTRA_DEBUG_LIBS})
    target_link_libraries( ${CMAKE_PROJECT_NAME}-exe debug ${EXTRA_DEBUG_LIB})
  endforeach()
  
endif(${CMAKE_PROJECT_NAME}_EXE)

#    ##### Installation targets #####
#    install(TARGETS ${_INSTALL_LIBS} EXPORT ${CMAKE_PROJECT_NAME}Targets
#      LIBRARY DESTINATION "lib${LIB_SUFFIX}"
#      ARCHIVE DESTINATION "lib${LIB_SUFFIX}"
#      RUNTIME DESTINATION bin)
#    
#    ##### Export files #####
#    if (APPLE)
#      set(PKG_PREFIX "${CMAKE_PROJECT_NAME}.framework/Resources")
#    elseif (WINDOWS)
#      set(PKG_PREFIX "cmake")
#    else ()
#      set(PKG_PREFIX "lib/cmake/${CMAKE_PROJECT_NAME}")
#    endif ()
#    
#    if(NOT ANDROID)
#      include(CMakePackageConfigHelpers)
#      write_basic_package_version_file("${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake"
#        VERSION ${${CMAKE_PROJECT_NAME}_VERSION}
#        COMPATIBILITY AnyNewerVersion
#      )
#    
#      install(EXPORT ${CMAKE_PROJECT_NAME}Targets
#        FILE ${CMAKE_PROJECT_NAME}Targets.cmake
#        NAMESPACE ${CMAKE_PROJECT_NAME}::
#        DESTINATION ${PKG_PREFIX}
#      )
#      install(
#        FILES
#        ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_PROJECT_NAME}Config.cmake
#        ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake
#        DESTINATION ${PKG_PREFIX}
#        COMPONENT Devel
#      )
#    
#      file(GLOB INCLUDE_FILES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/include/*.h)
#      file(GLOB BIN_INCLUDE_FILES ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/include/*.h)
#      foreach(_FNAME ${BIN_INCLUDE_FILES})
#        get_filename_component(_INCNAME ${_FNAME} NAME)
#        list(REMOVE_ITEM INCLUDE_FILES ${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/include/${_INCNAME})
#      endforeach()
#      list(APPEND INCLUDE_FILES ${BIN_INCLUDE_FILES})
#      install(FILES ${INCLUDE_FILES} DESTINATION include/${CMAKE_PROJECT_NAME})
#    
#      if(NOT (WINDOWS OR CYGWIN))
#        if(${CMAKE_PROJECT_NAME}_SHARED)
#          if (APPLE)
#              set(SOEXT "dylib")
#          else()
#              set(SOEXT "so")
#          endif()
#          install(CODE "
#            execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
#              \"lib${CMAKE_PROJECT_NAME}-1.0.${SOEXT}\" \"lib${CMAKE_PROJECT_NAME}.${SOEXT}\")")
#          install(FILES ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/lib${CMAKE_PROJECT_NAME}.${SOEXT} DESTINATION "lib${LIB_SUFFIX}")
#        endif()
#        if(FREEBSD)
#          # FreeBSD uses ${PREFIX}/libdata/pkgconfig
#          install(FILES ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/njlic.pc DESTINATION "libdata/pkgconfig")
#        else()
#          install(FILES ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/njlic.pc
#            DESTINATION "lib${LIB_SUFFIX}/pkgconfig")
#        endif()
#        install(PROGRAMS ${${CMAKE_PROJECT_NAME}_BINARY_DIR}/njlic-config DESTINATION bin)
#    
#        if(EMSCRIPTEN)
#          # file(GLOB_RECURSE EMSCRIPTEN_BINARY_FILES ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}-exe.*)
#          file(GLOB_RECURSE EMSCRIPTEN_BINARY_FILES ${CMAKE_BINARY_DIR}/index.*)
#          list(REMOVE_DUPLICATES EMSCRIPTEN_BINARY_FILES)
#          # list(REMOVE_ITEM EMSCRIPTEN_BINARY_FILES ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}-exe.html)
#          list(REMOVE_ITEM EMSCRIPTEN_BINARY_FILES ${CMAKE_BINARY_DIR}/index.html)
#          install(FILES ${EMSCRIPTEN_BINARY_FILES} DESTINATION bin)
#          install(FILES "${CMAKEIN_REPO_DIRECTORY}/platform.in/emscripten/executable/favicon-32x32.ico" DESTINATION bin)
#        endif()
#    
#        if (NOT APPLE)
#          INSTALL(TARGETS ${CMAKE_PROJECT_NAME}-exe 
#            RUNTIME DESTINATION bin 
#            BUNDLE DESTINATION bin
#            )
#        endif()
#    
#        # TODO: what about the .spec file? Is it only needed for RPM creation?
#        install(FILES "${${CMAKE_PROJECT_NAME}_SOURCE_DIR}/njlic.m4" DESTINATION "${CMAKE_INSTALL_FULL_DATAROOTDIR}/aclocal")
#      endif()
#    endif(NOT ANDROID)
#    
#    ##### Uninstall target #####
#    
#    if(NOT TARGET uninstall)
#      configure_file(
#          "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
#          "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
#          IMMEDIATE @ONLY)
#    
#      add_custom_target(uninstall
#          COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
#    endif()

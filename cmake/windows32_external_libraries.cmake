
message(STATUS "Platform is windows32 for engine")

include("${CMAKE_SOURCE_DIR}/cmake/DownloadSDL2_NJLIC.cmake")
list(APPEND ${CMAKE_PROJECT_NAME}_THIRDPARTY_INCLUDE_DIRS "${SDL2_INCLUDE_DIRS}")

find_package(SDL2_NJLIC REQUIRED)
list(APPEND EXTRA_LIBS ${SDL2_TARGETS})


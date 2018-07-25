
message(STATUS "Platform is linux for engine")

find_package(SDL2 REQUIRED)
list(APPEND EXTRA_LIBS ${SDL2_LIBRARY})
list(APPEND ${CMAKE_PROJECT_NAME}_THIRDPARTY_INCLUDE_DIRS "${SDL2_INCLUDE_DIR}")

find_package(GLEW REQUIRED)
list(APPEND EXTRA_LIBS ${GLEW_LIBRARY})
include_directories(${GLEW_INCLUDE_DIR})


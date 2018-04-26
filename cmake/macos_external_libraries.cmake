
message(STATUS "Platform is macos for engine")

find_package(SDL2 REQUIRED)
list(APPEND EXTRA_LIBS ${SDL2_LIBRARY})
include_directories(${SDL2_INCLUDE_DIR})

# find_package(GLEW REQUIRED)
# list(APPEND EXTRA_LIBS ${GLEW_LIBRARY})
# include_directories(${GLEW_INCLUDE_DIR})

file(GLOB SDL2_INCLUDE_FILES
  ${SDL2_INCLUDE_DIR}/*.h
  )

SOURCE_GROUP("THIRDPARTY\\SDL2" FILES ${SDL2_INCLUDE_FILES} )


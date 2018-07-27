
set(LIBRARY_NAME "bullet3")
set(SUB_LIBRARY_NAMES
  "Bullet2FileLoader"
  "Bullet3Collision"
  "Bullet3Common"
  "Bullet3Dynamics"
  "Bullet3Geometry"
  "Bullet3OpenCL_clew"
  "BulletCollision"
  "BulletDynamics"
  "BulletFileLoader"
  "BulletInverseDynamics"
  "BulletInverseDynamicsUtils"
  "BulletSoftBody"
  "BulletWorldImporter"
  "BulletXmlWorldImporter"
  "ConvexDecomposition"
  "GIMPACTUtils"
  "HACD"
  "LinearMath"
  )

# set(INCLUDE_FILE "btBulletCollisionCommon.h")

###########################################################################################################################

string(TOUPPER ${LIBRARY_NAME} LIBRARY_NAME_UPPER)

set(${LIBRARY_NAME_UPPER}_BASE_PATH "thirdparty/${LIBRARY_NAME}")

if(EMSCRIPTEN)
  set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/emscripten")
elseif(WINDOWS)
  if(ARCH_64)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/windows64")
  else()
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/windows32")
  endif()
elseif(APPLE)
  if(IOS)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/ios")
  elseif(TVOS)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/appletv")
  else()
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/macos")
  endif()
elseif(UNIX AND NOT APPLE AND NOT ANDROID)
  if(LINUX)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/linux")
  elseif(UNIX)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/unix")
  endif()
elseif(ANDROID)
    set(${LIBRARY_NAME_UPPER}_BASE_PATH "${${LIBRARY_NAME_UPPER}_BASE_PATH}/lib/android")
endif()

if(NOT EXISTS "${${LIBRARY_NAME_UPPER}_INCLUDE_DIR}")
  MESSAGE(FATAL_ERROR "Cannot find the include directory for ${LIBRARY_NAME} '${${LIBRARY_NAME_UPPER}_INCLUDE_DIR}'")
else()
  MESSAGE(STATUS "Include dir for ${LIBRARY_NAME_UPPER}_INCLUDE_DIR '${${LIBRARY_NAME_UPPER}_INCLUDE_DIR}'")
endif()

if(NOT EXISTS "${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}")
  MESSAGE(FATAL_ERROR "Cannot find the include directory for ${LIBRARY_NAME} '${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}'")
else()
  MESSAGE(STATUS "${LIBRARY_NAME_UPPER} Library Path: '${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}'")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)

# find_path(${LIBRARY_NAME_UPPER}_INCLUDE_DIR 
#   ${INCLUDE_FILE}
#   PATHS ${${LIBRARY_NAME_UPPER}_BASE_PATH}/include
#   )

foreach(LIB ${SUB_LIBRARY_NAMES})
  # find_path(${LIB}_INCLUDE_DIR ${LIBRARY_NAME_UPPER}_INCLUDE_DIR)
  # set(${LIB}_INCLUDE_DIR ${LIBRARY_NAME_UPPER}_INCLUDE_DIR)

  if(NOT ${LIB}_LIBRARY)
    find_library(${LIB}_LIBRARY_RELEASE
      NAMES ${LIB}
      PATHS "${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}"
      PATH_SUFFIXES Release
      )
    find_library(${LIB}_LIBRARY_DEBUG
      NAMES ${LIB}
      PATHS "${CMAKE_BINARY_DIR}/${${LIBRARY_NAME_UPPER}_BASE_PATH}"
      PATH_SUFFIXES Debug
      )
    select_library_configurations(${LIB})
  endif ()

  find_package_handle_standard_args(${LIB}
    REQUIRED_VARS ${LIBRARY_NAME_UPPER}_INCLUDE_DIR ${LIB}_LIBRARY)

  if(${LIB}_FOUND)

    set(${LIB}_INCLUDE_DIRS ${${LIBRARY_NAME_UPPER}_INCLUDE_DIR})

    # if(NOT ${LIB}_LIBRARIES)
    #   set(${LIB}_LIBRARIES ${${LIB}_LIBRARY})
    # endif()
    list(APPEND ${LIBRARY_NAME_UPPER}_LIBRARIES ${${LIB}_LIBRARY})

    if (NOT TARGET ${LIB})
      add_library(${LIB} UNKNOWN IMPORTED)
      set_target_properties(${LIB} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${${LIB}_INCLUDE_DIRS}")

      if(${LIB}_LIBRARY_RELEASE)
        set_property(TARGET ${LIB} APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(${LIB} PROPERTIES IMPORTED_LOCATION_RELEASE "${${LIB}_LIBRARY_RELEASE}")
      endif()

      if(${LIB}_LIBRARY_DEBUG)
        set_property(TARGET ${LIB} APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(${LIB} PROPERTIES IMPORTED_LOCATION_DEBUG "${${LIB}_LIBRARY_DEBUG}")
      endif()

      if(NOT ${LIB}_LIBRARY_RELEASE AND NOT ${LIB}_LIBRARY_DEBUG)
        set_property(TARGET ${LIB} APPEND PROPERTY IMPORTED_LOCATION "${${LIB}_LIBRARY}")
      endif()

      list(APPEND ${LIBRARY_NAME_UPPER}_TARGETS ${LIB})
    endif()
  endif()
endforeach()

mark_as_advanced(${LIBRARY_NAME_UPPER}_INCLUDE_DIR)

MESSAGE(STATUS "${LIBRARY_NAME_UPPER}_INCLUDE_DIR ${${LIBRARY_NAME_UPPER}_INCLUDE_DIR}")
MESSAGE(STATUS "${LIBRARY_NAME_UPPER}_LIBRARIES ${${LIBRARY_NAME_UPPER}_LIBRARIES}")
MESSAGE(STATUS "${LIBRARY_NAME_UPPER}_TARGETS ${${LIBRARY_NAME_UPPER}_TARGETS}")

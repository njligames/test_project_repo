macro(SET_OPTION _NAME _DESC)
  list(APPEND ALLOPTIONS ${_NAME})
  if(${ARGC} EQUAL 3)
    set(_DEFLT ${ARGV2})
  else()
    set(_DEFLT OFF)
  endif()
  option(${_NAME} ${_DESC} ${_DEFLT})
endmacro()

macro(DEP_OPTION _NAME _DESC _DEFLT _DEPTEST _FAILDFLT)
  list(APPEND ALLOPTIONS ${_NAME})
  cmake_dependent_option(${_NAME} ${_DESC} ${_DEFLT} ${_DEPTEST} ${_FAILDFLT})
endmacro()

macro(OPTION_STRING _NAME _DESC _VALUE)
  list(APPEND ALLOPTIONS ${_NAME})
  set(${_NAME} ${_VALUE} CACHE STRING "${_DESC}")
  set(HAVE_${_NAME} ${_VALUE})
ENDMACRO()

# Message Output
macro(MESSAGE_WARN _TEXT)
  message(STATUS "*** WARNING: ${_TEXT}")
endmacro()

macro(MESSAGE_ERROR _TEXT)
  message(FATAL_ERROR "*** ERROR: ${_TEXT}")
endmacro()

macro(MESSAGE_BOOL_OPTION _NAME _VALUE)
  if(${_VALUE})
    message(STATUS "  ${_NAME}:\tON")
  else()
    message(STATUS "  ${_NAME}:\tOFF")
  endif()
endmacro()

macro(MESSAGE_TESTED_OPTION _NAME)
  set(_REQVALUE ${${_NAME}})
  set(_PAD " ")
  if(${ARGC} EQUAL 2)
    set(_PAD ${ARGV1})
  endif()
  if(NOT HAVE_${_NAME})
    set(HAVE_${_NAME} OFF)
  elseif("${HAVE_${_NAME}}" MATCHES "1|TRUE|YES|Y")
    set(HAVE_${_NAME} ON)
  endif()
  message(STATUS "  ${_NAME}${_PAD}(Wanted: ${_REQVALUE}): ${HAVE_${_NAME}}")
endmacro()

macro(LISTTOSTR _LIST _OUTPUT)
  if(${ARGC} EQUAL 3)
    # prefix for each element
    set(_LPREFIX ${ARGV2})
  else()
    set(_LPREFIX "")
  endif()
  # Do not use string(REPLACE ";" " ") here to avoid messing up list
  # entries
  foreach(_ITEM ${${_LIST}})
    set(${_OUTPUT} "${_LPREFIX}${_ITEM} ${${_OUTPUT}}")
  endforeach()
endmacro()

macro(CHECK_OBJC_SOURCE_COMPILES SOURCE VAR)
  set(PREV_REQUIRED_DEFS "${CMAKE_REQUIRED_DEFINITIONS}")
  set(CMAKE_REQUIRED_DEFINITIONS "-ObjC ${PREV_REQUIRED_DEFS}")
  CHECK_C_SOURCE_COMPILES(${SOURCE} ${VAR})
  set(CMAKE_REQUIRED_DEFINITIONS "${PREV_REQUIRED_DEFS}")
endmacro()


MACRO(SUBDIRLIST result curdir dirs)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
      LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})

  FOREACH(subdir ${dirlist})
    LIST (APPEND ${dirs} "${curdir}/${subdir}")
    SUBDIRLIST(result "${curdir}/${subdir}" ${dirs})
  ENDFOREACH()
ENDMACRO()

#litle macro that puts files in source_groups matching the directory hierarchy for VS project sln
MACRO(SOURCE_GROUP_BY_FOLDER RELATIVE_DIRECTORY)
  SET(SOURCE_GROUP_DELIMITER "/")
  SET(source_group_root "Source Files${SOURCE_GROUP_DELIMITER}")
  SET(last_dir "")
  SET(files "")

  list(APPEND SOURCE_GROUP_FILES ${SOURCE_FILES})
  list(APPEND SOURCE_GROUP_FILES ${INCLUDE_FILES})
  list(APPEND SOURCE_GROUP_FILES ${INTERFACE_FILES})
  
  LIST(SORT SOURCE_GROUP_FILES)
  FOREACH(file ${SOURCE_GROUP_FILES})
    file(RELATIVE_PATH relative_file ${RELATIVE_DIRECTORY} ${file})
    # MESSAGE(STATUS "relative_file ${relative_file} file ${file} CMAKE_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}")
    GET_FILENAME_COMPONENT(dir "${relative_file}" PATH)
    IF (NOT "${dir}" STREQUAL "${last_dir}")
      IF (files)
        SOURCE_GROUP("${source_group_root}${last_dir}" FILES ${files})
      ENDIF (files)
      SET(files "")
    ENDIF (NOT "${dir}" STREQUAL "${last_dir}")
    SET(files ${files} ${file})
    SET(last_dir "${dir}")
  ENDFOREACH(file)
  IF (files)
    SOURCE_GROUP("${source_group_root}${last_dir}" FILES ${files})
  ENDIF (files)
ENDMACRO()


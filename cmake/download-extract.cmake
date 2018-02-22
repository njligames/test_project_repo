###########################################################
#
# Download a tar.gz file and decompres it into the target
#
# note:
#   To compress use: tar -zcvf ${TARGET_DIRECTORY}.tar.gz ${TARGET_DIRECTORY}
#
# PREFIX -  The workding directory
#
# URL - The url to get the file
#
# DOWNLOAD_DIR - Where to download the zip, temporarily
#
# EXPECTED_SHA256 - (Use SKIP to bypass with out checking)
#
# TARGET_DIRECTORY - The name of the tar.gz to download and extract.
#
###################################################

function(DOWNLOAD_EXTRACT_TAR PREFIX URL DOWNLOAD_DIR EXPECTED_SHA256 TARGET_DIRECTORY)

  if(NOT DEFINED PREFIX)
    message(FATAL_ERROR "PREFIX must be defined.")
  endif()

  if(NOT DEFINED URL)
    message(FATAL_ERROR "URL must be defined.")
  endif()

  if(NOT DEFINED DOWNLOAD_DIR)
    message(FATAL_ERROR "DOWNLOAD_DIR must be defined.")
  endif()

  if(NOT DEFINED EXPECTED_SHA256)
    message(FATAL_ERROR "EXPECTED_SHA256 must be defined.")
  endif()

  if(NOT DEFINED TARGET_DIRECTORY)
    message(FATAL_ERROR "TARGET_DIRECTORY must be defined.")
  endif()

  #MESSAGE("${PREFIX}")
  #MESSAGE("${URL}")
  #MESSAGE("${DOWNLOAD_DIR}")
  #MESSAGE("${EXPECTED_SHA256}")
  #MESSAGE("${TARGET_DIRECTORY}")

  set(SRC_DIR ${PREFIX}/${TARGET_DIRECTORY})

  if(TIMEOUT)
    set(timeout_args TIMEOUT ${timeout})
    set(timeout_msg "${timeout} seconds")
  else()
    set(timeout_args "")
    set(timeout_msg "none")
  endif()

  set(fname ${TARGET_DIRECTORY}.tar.gz)
  set(file ${DOWNLOAD_DIR}/${fname})
  message(STATUS "file: ${file}")

  message(STATUS "downloading...
       src='${URL}'
       dst='${file}'
       timeout='${timeout_msg}'")

  file(DOWNLOAD ${URL} ${file}
    ${timeout_args}
    ${hash_args}
    STATUS status
    LOG log
    SHOW_PROGRESS
    )

  list(GET status 0 status_code)
  list(GET status 1 status_string)

  if(NOT status_code EQUAL 0)
    message(FATAL_ERROR "error: downloading '${URL}' failed
    status_code: ${status_code}
    status_string: ${status_string}
    log: ${log}
  ")
  endif()

  set(NULL_SHA256 "0000000000000000000000000000000000000000000000000000000000000000")

  # Allow users to use "SKIP" or "skip" as the sha256 to skip checking the hash.
  # You can still use the all zeros hash too.
  if((EXPECTED_SHA256 STREQUAL "SKIP") OR (EXPECTED_SHA256 STREQUAL "skip"))
    set(EXPECTED_SHA256 ${NULL_SHA256})
  endif()

  # We could avoid computing the SHA256 entirely if a NULL_SHA256 was given,
  # but we want to warn users of an empty file.
  file(SHA256 ${file} ACTUAL_SHA256)
  if(ACTUAL_SHA256 STREQUAL "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    # File was empty.  It's likely due to lack of SSL support.
    message(FATAL_ERROR
      "Failed to download ${URL}.  The file is empty and likely means CMake "
      "was built without SSL support.  Please use a version of CMake with "
      "proper SSL support.  See "
      "https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites "
      "for more information.")
  elseif((NOT EXPECTED_SHA256 STREQUAL NULL_SHA256) AND
         (NOT EXPECTED_SHA256 STREQUAL ACTUAL_SHA256))
    # Wasn't a NULL SHA256 and we didn't match, so we fail.
    message(FATAL_ERROR
      "Failed to download ${URL}.  Expected a SHA256 of "
      "${EXPECTED_SHA256} but got ${ACTUAL_SHA256} instead.")
  endif()

  message(STATUS "downloading... done")

  # Slurped from a generated extract-TARGET_DIRECTORY.cmake file.
  message(STATUS "extracting...
       src='${file}'
       dst='${SRC_DIR}'")

  if(NOT EXISTS "${file}")
    message(FATAL_ERROR "error: file to extract does not exist: '${file}'")
  endif()
  #
  # Prepare a space for extracting:
  #
  set(i 1234)
  while(EXISTS "${SRC_DIR}/../ex-${TARGET_DIRECTORY}${i}")
    math(EXPR i "${i} + 1")
  endwhile()
  set(ut_dir "${SRC_DIR}/../ex-${TARGET_DIRECTORY}${i}")
  file(MAKE_DIRECTORY "${ut_dir}")

  # Extract it:
  #
  message(STATUS "extracting... [tar xfz]")
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${file}
    WORKING_DIRECTORY ${ut_dir}
    RESULT_VARIABLE rv)

  if(NOT rv EQUAL 0)
    message(STATUS "extracting... [error clean up]")
    file(REMOVE_RECURSE "${ut_dir}")
    message(FATAL_ERROR "error: extract of '${file}' failed")
  endif()

  # Analyze what came out of the tar file:
  #
  message(STATUS "extracting... [analysis]")
  file(GLOB contents "${ut_dir}/*")
  list(LENGTH contents n)
  if(NOT n EQUAL 1 OR NOT IS_DIRECTORY "${contents}")
    set(contents "${ut_dir}")
  endif()

  # Move "the one" directory to the final directory:
  #
  message(STATUS "extracting... [rename]")
  file(REMOVE_RECURSE ${SRC_DIR})
  get_filename_component(contents ${contents} ABSOLUTE)
  file(RENAME ${contents} ${SRC_DIR})

  # Clean up:
  #
  message(STATUS "extracting... [clean up]")
  file(REMOVE_RECURSE "${ut_dir}")

  file(REMOVE ${file})

  message(STATUS "extracting... done")

endfunction(DOWNLOAD_EXTRACT_TAR PREFIX URL DOWNLOAD_DIR EXPECTED_SHA256 TARGET_DIRECTORY)

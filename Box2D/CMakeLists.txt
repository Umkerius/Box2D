cmake_minimum_required (VERSION 2.8)
project (Box2D)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

include (common.cmake)

enumerate_files_for_humans("Box2D" "${source_patterns}" source_files)
enumerate_files_for_humans("Box2D" "${header_patterns}" header_files)

source_group("Sources" FILES ${source_files})
source_group("Headers" FILES ${header_files})

add_library(${PROJECT_NAME} STATIC ${source_files} ${header_files})

cmake_minimum_required(VERSION 2.8)

macro(enumerate_files_for_humans root_dir patterns output)
  foreach(pattern ${patterns})
    file(GLOB files "${root_dir}/${pattern}")
    list(APPEND ${output} ${files})
  endforeach()
endmacro()

macro(add_flags flags flag)
  set(${flags} "${${flags}} ${flag}")
endmacro()

set(header_patterns *.h *.hpp)
set(code_patterns *.c *.cc *.cpp *.cxx)
list(APPEND source_patterns ${header_patterns} ${code_patterns})

if (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
  set(clang_compiler 1)
elseif (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
  set(gcc_compiler 1)
elseif (${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel")
  set(intel_compiler 1)
elseif (MSVC)
  set(vs_compiler 1)
endif()

if (vs_compiler)
  add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS -DNOMINMAX -DWIN32_LEAN_AND_MEAN)
endif ()

if (clang_compiler OR gcc_compiler)
  add_flags(additional_cxx_flags "-std=c++14 -Wall -Wextra -Wpedantic")
endif()

if (intel_compiler)
  add_flags(additional_cxx_flags "-std=c++14")
endif()

if (vs_compiler)
  add_flags(additional_cxx_flags "/std:c++14")
  # Static runtime
  add_flags(additional_cxx_flags_debug "/MTd")
  add_flags(additional_cxx_flags_release "/MT")
  
  # Full optimization and specialization on Intel 64
  add_flags(additional_cxx_flags_release "/Qpar /Ox /favor:INTEL64")
endif()

# enables LTO
if (vs_compiler)
  set(compiler_lto_flags "/GL")
  set(linker_lto_flags "/LTCG")
endif()

if (compiler_lto_flags OR linker_lto_flags)
  add_flags(additional_cxx_flags_release "${compiler_lto_flags}")
  add_flags(additional_exe_linker_flags_release "${linker_lto_flags}")
  add_flags(additional_shared_linker_flags_release "${linker_lto_flags}")
  add_flags(additional_static_linker_flags_release "${linker_lto_flags}")
endif()

# set flags to cmake variables
add_flags(CMAKE_CXX_FLAGS ${additional_cxx_flags})

if (vs_compiler)
  add_flags(CMAKE_CXX_FLAGS_DEBUG ${additional_cxx_flags_debug})
  add_flags(CMAKE_CXX_FLAGS_RELEASE ${additional_cxx_flags_release})
  add_flags(CMAKE_EXE_LINKER_FLAGS_RELEASE ${additional_exe_linker_flags_release})
  add_flags(CMAKE_SHARED_LINKER_FLAGS_RELEASE ${additional_shared_linker_flags_release})
  add_flags(CMAKE_STATIC_LINKER_FLAGS_RELEASE ${additional_static_linker_flags_release})
elseif (CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_flags(CMAKE_CXX_FLAGS ${additional_cxx_flags_debug})
elseif (CMAKE_BUILD_TYPE STREQUAL "Release")
  add_flags(CMAKE_CXX_FLAGS ${additional_cxx_flags_release})
  add_flags(CMAKE_EXE_LINKER_FLAGS ${additional_exe_linker_flags_release})
  add_flags(CMAKE_SHARED_LINKER_FLAGS ${additional_shared_linker_flags_release})
  add_flags(CMAKE_STATIC_LINKER_FLAGS ${additional_static_linker_flags_release})
endif()

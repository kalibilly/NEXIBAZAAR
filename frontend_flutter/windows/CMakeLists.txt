cmake_minimum_required(VERSION 3.14)
project(nexi_bazaar LANGUAGES CXX)

# The Flutter tooling requires that developers have a version of Visual Studio installed that
# includes CMake 3.14 or later. You should not increase this version, as doing so will cause
# the install step to fail, which the Flutter tooling uses to finalize setup.
set(FLUTTER_MINIMUM_CMAKE_VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "nexi_bazaar")
set(FLUTTER_APPLICATION_NAME "NexiBazaar")
set(FLUTTER_APPLICATION_VERSION "1.0.0")
set(FLUTTER_APPLICATION_VERSION_BUILD 1)

# Append all generated cmake files to the module path.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/flutter/cmake")

# Includes the top-level CMakeLists.txt for the flutter package.
include(${FLUTTER_MANAGED_CMAKE})

# System default properties that Flutter uses.
include(flutter/generated_plugins.cmake)

# Enable CMP0063 to have visibility
if(POLICY CMP0063)
  cmake_policy(SET CMP0063 NEW)
endif()

# Define build type.
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

# Compilation flags.
if(NOT MSVC)
  set(CMAKE_CXX_FLAGS "-Wall")
endif()

add_subdirectory("runner")

# Flutter build outputs.
set(FLUTTER_LIBRARY "${FLUTTER_BUILD_DIR}/flutter_windows.dll")
set(FLUTTER_ICU_DATA_DIR "${FLUTTER_BUILD_DIR}/icudtl.dat")

# Application build.
string(APPEND CMAKE_EXE_LINKER_FLAGS " /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup")

add_executable(${PROJECT_NAME}
  WIN32
  "${FLUTTER_MANAGED_CMAKE}"
  "runner/flutter_window.cpp"
  "runner/win32_window.cpp"
  "runner/utils.cpp"
  "runner/main.cpp"
  "${FLUTTER_ICON_PATH}"
)

set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED YES
)

target_compile_options(${PROJECT_NAME} PRIVATE /W4 /WX)
target_link_options(${PROJECT_NAME} PRIVATE /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup)

target_include_directories(${PROJECT_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/runner"
  "${FLUTTER_MANAGED_CMAKE}"
)

target_link_libraries(${PROJECT_NAME} PRIVATE flutter flutter_windows)

add_dependencies(${PROJECT_NAME} flutter_assemble)

# Copy the dependent dll next to the executable.
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -P
    ${FLUTTER_MANAGED_CMAKE}/copy_flutter_dll.cmake
)

# Copy ICU data files to the build directory for the runner to find.
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
    "${FLUTTER_ICU_DATA_DIR}" "${CMAKE_BINARY_DIR}/$<CONFIG>/"
)

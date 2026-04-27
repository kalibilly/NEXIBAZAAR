cmake_minimum_required(VERSION 3.10)
project(nexi_bazaar)

set(FLUTTER_TARGET_PLATFORM "linux-x64")

# Add Flutter dependencies
set(FLUTTER_MANAGED_CMAKE "linux/cmake/managed.cmake")
include(${FLUTTER_MANAGED_CMAKE})

set(PROJECT_SOURCES
  "linux/main.cc"
  "linux/my_application.cc"
)

add_executable(${FLUTTER_APPLICATION_NAME} ${PROJECT_SOURCES})

target_include_directories(${FLUTTER_APPLICATION_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/linux"
  "${CMAKE_CURRENT_BINARY_DIR}/flutter/generated_includes"
)

target_link_libraries(${FLUTTER_APPLICATION_NAME} PRIVATE
  flutter
  PkgConfig::GTK
  PkgConfig::GLIB
  PkgConfig::GIO
)

# Define build type
set_target_properties(${FLUTTER_APPLICATION_NAME} PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED YES
)

if(DEFINED FLUTTER_PLUGIN_LIST)
  foreach(plugin ${FLUTTER_PLUGIN_LIST})
    add_subdirectory("linux/plugins/${plugin}")
    target_link_libraries(${FLUTTER_APPLICATION_NAME} PRIVATE ${plugin}_plugin)
  endforeach()
endif()

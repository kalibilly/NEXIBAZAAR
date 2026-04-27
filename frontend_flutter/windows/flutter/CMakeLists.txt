cmake_minimum_required(VERSION 3.14)

set(FLUTTER_MANAGED_CMAKE "Generated")
set(FLUTTER_VERSION "3.22.0")
set(FLUTTER_VERSION_MAJOR 3)
set(FLUTTER_VERSION_MINOR 22)
set(FLUTTER_VERSION_PATCH 0)
set(FLUTTER_VERSION_BUILD 0)

# Disable mangling of the Windows API
set(FLUTTER_PRECOMPILED_DART_SDK "windows-x64")

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR AMD64)

# Architecture detection
if(CMAKE_GENERATOR MATCHES "ARM64")
  set(FLUTTER_TARGET_PLATFORM_SYSROOT arm64)
endif()

set(FLUTTER_BUILD_DIR "${CMAKE_BINARY_DIR}")

set(FLUTTER_EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")
set(FLUTTER_MANAGED_DIR "${FLUTTER_EPHEMERAL_DIR}/flutter_managed_plugins_dir")

set(FLUTTER_EXECUTABLE "${FLUTTER_ROOT}/bin/flutter.bat")

set(FLUTTER_BUILD_OUTPUTS
  "${FLUTTER_BUILD_DIR}/flutter_assets"
  "${FLUTTER_BUILD_DIR}/flutter_windows.dll"
  "${FLUTTER_BUILD_DIR}/flutter_windows.dll.exp"
  "${FLUTTER_BUILD_DIR}/flutter_windows.lib"
  "${FLUTTER_BUILD_DIR}/flutter_tester.exe"
  "${FLUTTER_BUILD_DIR}/icudtl.dat"
)

foreach(output ${FLUTTER_BUILD_OUTPUTS})
  if(NOT EXISTS ${output})
    set(FLUTTER_BUILD_OUTPUTS_MISSING TRUE)
  endif()
endforeach(output)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${FLUTTER_EPHEMERAL_DIR}")

include(generated_plugins.cmake)

cmake_minimum_required(VERSION 3.13)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

include("${EPHEMERAL_DIR}/generated_config.cmake")

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/libflutter_linux_gtk.so")

set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat")

set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/linux/${FLUTTER_TARGET_PLATFORM}")

set(AOT_LIBRARY "${PROJECT_BUILD_DIR}/lib/libapp.so")

list(APPEND FLUTTER_ASSET_DIR
  "${PROJECT_DIR}/build/flutter_assets"
)

add_library(flutter INTERFACE)

target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)

target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")

add_custom_target(flutter_assemble
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.sh"
      ${FLUTTER_TARGET_PLATFORM} ${CMAKE_BUILD_TYPE}
  VERBATIM
)

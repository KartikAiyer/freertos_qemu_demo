# Set the desired ARM toolchain version
set(ARM_TOOLCHAIN_VERSION "13.2.Rel1")

# Set the download directory
set(ARM_TOOLCHAIN_PARENT_DIR "${CMAKE_BINARY_DIR}/arm-toolchain")

message(STATUS "Looking and downloading for toolchain")

set(HOST_CHIP_VERSION "")
if(APPLE)
  message(STATUS "Selecting Apple Silicon host compiler toolchain for ${CMAKE_HOST_SYSTEM_PROCESSOR}")
  set(HOST_CHIP_VERSION "darwin-${CMAKE_HOST_SYSTEM_PROCESSOR}")
elseif(CMAKE_HOST_WIN32)
  if(CMAKE_GENERATOR MATCHES "MinGW")
    set(HOST_CHIP_VERSION "mingw-w64-i686")
  else()
    message(FATAL_ERROR "Only MinGW Windows generator supported")
  endif()
else()
  message(
    STATUS "Selecting Linux Host Chip version ${CMAKE_HOST_SYSTEM_PROCESSOR}")
  set(HOST_CHIP_VERSION "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif()

# Set the URL to download the ARM toolchain
set(ARM_TOOLCHAIN_URL
    "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_TOOLCHAIN_VERSION}/binrel/arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-${HOST_CHIP_VERSION}-arm-none-eabi.tar.xz"
)
set(ARM_TOOLCHAIN_FULL_NAME_DIR "${ARM_TOOLCHAIN_PARENT_DIR}/arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-${HOST_CHIP_VERSION}-arm-none-eabi")
set(ARM_TOOLCHAIN_DIR "${ARM_TOOLCHAIN_PARENT_DIR}/arm-gnu-toolchain")
# Set the toolchain paths
set(ARM_TOOLCHAIN_BIN_DIR
    "${ARM_TOOLCHAIN_DIR}/bin"
)
# Create a custom command to download the ARM toolchain
if(NOT EXISTS "${ARM_TOOLCHAIN_BIN_DIR}/arm-none-eabi-gcc")
  message(STATUS "Downloading ARM toolchain from ${ARM_TOOLCHAIN_URL}")
  file(DOWNLOAD "${ARM_TOOLCHAIN_URL}"
       "${ARM_TOOLCHAIN_PARENT_DIR}/arm-toolchain.tar.xz" SHOW_PROGRESS)
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xf
            "${ARM_TOOLCHAIN_PARENT_DIR}/arm-toolchain.tar.xz"
    WORKING_DIRECTORY "${ARM_TOOLCHAIN_PARENT_DIR}")
  execute_process(COMMAND mv "${ARM_TOOLCHAIN_FULL_NAME_DIR}" "${ARM_TOOLCHAIN_DIR}" WORKING_DIRECTORY "${ARM_TOOLCHAIN_PARENT_DIR}")
endif()

# Set the target system root
set(CMAKE_FIND_ROOT_PATH "${ARM_TOOLCHAIN_DIR}")

# Search for programs only in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
# Disable compiler checks
set(CMAKE_C_COMPILER_WORKS TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)
set(CMAKE_C_ABI_COMPILED TRUE)
set(CMAKE_CXX_ABI_COMPILED TRUE)

set(CMAKE_C_COMPILER "${ARM_TOOLCHAIN_BIN_DIR}/arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "${ARM_TOOLCHAIN_BIN_DIR}/arm-none-eabi-g++")
set(CMAKE_ASM_COMPILER "${ARM_TOOLCHAIN_BIN_DIR}/arm-none-eabi-gcc")

# Set the target system and architecture
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Add the toolchain include directories
include_directories(
  "${ARM_TOOLCHAIN_DIR}/arm-none-eabi/include"
)

# Add the toolchain library directories
link_directories(
  "${ARM_TOOLCHAIN_DIR}/arm-none-eabi/lib"
)



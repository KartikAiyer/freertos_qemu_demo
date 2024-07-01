cmake_minimum_required(VERSION 3.22)
project(qemu_demo C)


set(FREERTOS_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/FreeRTOS/FreeRTOS/Source)
set(FREERTOS_PORTABLE_DIR "${FREERTOS_SOURCES_DIR}/portable")
set(FREERTOS_PORTABLE_M3_DIR "${FREERTOS_PORTABLE_DIR}/GCC/ARM_CM3_MPU")
set(FREERTOS_QEMU_MPS2_DIR ${CMAKE_CURRENT_SOURCE_DIR}/FreeRTOS/FreeRTOS/Demo/CORTEX_MPU_M3_MPS2_QEMU_GCC)

list(APPEND 
  sources 
  "${FREERTOS_QEMU_MPS2_DIR}/init/startup.c" 
  "${FREERTOS_QEMU_MPS2_DIR}/syscall.c" 
  "${FREERTOS_QEMU_MPS2_DIR}/main.c" 
  "${FREERTOS_QEMU_MPS2_DIR}/app_main.c" 
  "${FREERTOS_QEMU_MPS2_DIR}/mpu_demo.c" 
  "${FREERTOS_PORTABLE_M3_DIR}/port.c"
  "${FREERTOS_PORTABLE_M3_DIR}/mpu_wrappers_v2_asm.c"
  "${FREERTOS_PORTABLE_DIR}/Common/mpu_wrappers.c"
  "${FREERTOS_PORTABLE_DIR}/Common/mpu_wrappers_v2.c"
  "${FREERTOS_PORTABLE_DIR}/MemMang/heap_4.c"
  "${FREERTOS_SOURCES_DIR}/list.c"
  "${FREERTOS_SOURCES_DIR}/tasks.c"
  "${FREERTOS_SOURCES_DIR}/queue.c"
  "${FREERTOS_SOURCES_DIR}/timers.c"
  "${FREERTOS_SOURCES_DIR}/event_groups.c"
  "${FREERTOS_SOURCES_DIR}/stream_buffer.c"
)

list(APPEND 
  includeDirs
  "${FREERTOS_QEMU_MPS2_DIR}"
  "${FREERTOS_QEMU_MPS2_DIR}/CMSIS"
  "${FREERTOS_SOURCES_DIR}/include"
  "${FREERTOS_PORTABLE_M3_DIR}"
)

list(APPEND
  DEFINES
  -DHEAP_4
)

list(APPEND
  CFLAGS
  -mthumb
  -mcpu=cortex-m3
  -Wall
  -Wextra
  -Wshadow
  -Wno-unused-parameter
  -g3
  -Og
  -ffunction-sections
  -fdata-sections
  -save-temps=obj
)

list(APPEND
  LDFLAGS
  "${CFLAGS}"
  -T ${FREERTOS_QEMU_MPS2_DIR}/scripts/mps2_m3.ld
  -Wl,-Map=${CMAKE_BINARY_DIR}/output.map,--gc-sections
  -nostartfiles -nostdlib -nolibc -nodefaultlibs
)

add_executable(qemu_demo "${sources}")
target_include_directories(qemu_demo PRIVATE "${includeDirs}")
target_compile_definitions(qemu_demo PRIVATE "${DEFINES}")
target_compile_options(qemu_demo PRIVATE "${CFLAGS}")
target_link_options(qemu_demo PRIVATE "${LDFLAGS}")

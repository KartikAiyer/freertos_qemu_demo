Hello folks,

I'm trying to create a CMake build for the CORTEX_MPU_M3_MPS2_QEMU_GCC demo. In case it matters, I'm doning this because
I intend to use FreeRTOS and QEMU in another CMake based project of mine and am using this as a learning step to get the 
build working.

I've uploaded my [mini project to github](https://github.com/KartikAiyer/freertos_qemu_demo) for your reference.

I have a toolchain file that will download the ARM toolchain v13.2.Rel1 and use it for the CMake build. 
I have also provided a [env.sh](./env.sh) which you can source to setup your path to run the FreeRTOS supplied
makefile based build of the demo. 

I'm currently trying this on an M1 based Macbook air but I've setup the build to work on Linux 
as well (though I haven't tried it on Linux).

## My Problem

I generate the build using both the FreeRTOS supplied Makefile for the Demo and with my CMake build.
When I launch my CMake based and connect GDB to it, I can see that my code calls the `HardFault_Handler`
the moment it tries to create the stack variable 
```c
TaskParameters_t xROAccessTaskParameters =
    {
        .pvTaskCode     = prvROAccessTask,
        .pcName         = "ROAccess",
        .usStackDepth   = configMINIMAL_STACK_SIZE,
        .pvParameters   = NULL,
        .uxPriority     = tskIDLE_PRIORITY,
        .puxStackBuffer = xROAccessTaskStack,
        .xRegions       =
        {
            { ucSharedMemory,                  SHARED_MEMORY_SIZE,
              portMPU_REGION_PRIVILEGED_READ_WRITE_UNPRIV_READ_ONLY |
              portMPU_REGION_EXECUTE_NEVER },
            { ( void * ) ucROTaskFaultTracker, SHARED_MEMORY_SIZE,
              portMPU_REGION_READ_WRITE | portMPU_REGION_EXECUTE_NEVER },
            { 0,                               0,                 0},
        }
    };
```
When I launch the build generated using the FreeRTOS based Makefile, the code does not crash.

I've tried to make my CMakeLists.txt file do exactly what the Makefile does and I'm not able to 
trace why there is a difference. I tried comparing the output.map files from both builds it looks
like symbols are created at different addresses. 

I could really use some help with debugging this. 


## Buliding the cmake project

You will need to do this once to download the toolchain for reuse with the makefile based build
All of the commands here are based on starting of at the root of the mini project

```bash
cd ~/Downloads/freertos_qemu_demo # Go To the downloaded freertos_qemu_demo folder
```

```bash
mkdir build
cd build
cmake --preset=default .. && make VERBOSE=1
cd ..
```
The above does build with verbose logs. The Cmake build by default builds a debug version of the 
code.

### Running the projct in QEMU and debugging

I source the `env.sh` so that the toolchain binaries are in my path
```bash
source env.sh
```
Launching QEMU

```bash
qemu-system-arm -machine mps2-an385 -monitor null -semihosting --semihosting-config enable=on,target=native -kernel ./build/qemu_demo -serial stdio -nographic -s -S
```

I then launch GDB

```bash
arm-none-eabi-gdb -q ./build/qemu_demo
Reading symbols from ./build/qemu_demo...
(gdb) target remote:1234
Remote debugging using :1234
Reset_Handler () at /Users/kartikaiyer/fun/qemu_demo/FreeRTOS/FreeRTOS/Demo/CORTEX_MPU_M3_MPS2_QEMU_GCC/init/startup.c:50
50          __asm volatile ( "ldr r0, =_estack" );
(gdb) b HardFault_Handler
Breakpoint 1 at 0x10584: file /Users/kartikaiyer/fun/qemu_demo/FreeRTOS/FreeRTOS/Demo/CORTEX_MPU_M3_MPS2_QEMU_GCC/init/startup.c, line 130.
(gdb) c
Continuing.

Breakpoint 1, HardFault_Handler ()
    at /Users/kartikaiyer/fun/qemu_demo/FreeRTOS/FreeRTOS/Demo/CORTEX_MPU_M3_MPS2_QEMU_GCC/init/startup.c:130
130         __asm volatile
(gdb)
```

## Building the FreeRTOS supplied Makefile

You will need to run the CMake build so that the toolchain is downloaded. Then source the `env.sh` file

```bash
source env.sh
```
### Building

```bash
cd FreeRTOS/FreeRTOS/Demo/CORTEX_MPU_M3_MPS2_QEMU_GCC
make DEBUG=1 VERBOSE=1
```

### Running
The following is executed in the Demo folder

Launch QEMU

```bash
qemu-system-arm -machine mps2-an385 -monitor null -semihosting --semihosting-config enable=on,target=native -kernel ./build/RTOSDemo.axf -serial stdio -nographic -s -S
```

Launching GDB

```bash
arm-none-eabi-gdb -q ./build/RTOSDemo.axf
Reading symbols from ./build/RTOSDemo.axf...
(gdb) target remote:1234
Remote debugging using :1234
Reset_Handler () at init/startup.c:50
50          __asm volatile ( "ldr r0, =_estack" );
(gdb) b HardFault_Handler
Breakpoint 1 at 0x10614: file init/startup.c, line 130.
(gdb) c
Continuing.
```
As you can see above, there is no crash.

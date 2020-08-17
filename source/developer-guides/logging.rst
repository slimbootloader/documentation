.. _logging:

Logging
---------

|SPN| provides logging for debugging purpose. It can be configured at build time
for verbosity. One can control debug messages in multiple ways by modifying the following PCDs defined in ``BootloaderCorePkg.yaml`` file:

+------------------------------+------------------------------------------------------------------+
| PCD Name                     | Description                                                      |
+==============================+==================================================================+
| PcdFixedDebugPrintErrorLevel | Build time debug message level compiled into the image           |
+------------------------------+------------------------------------------------------------------+
| PcdDebugPropertyMask         | Runtime debug message level sent to the console                  |
+------------------------------+------------------------------------------------------------------+
| PcdDebugOutputDeviceMask     | Debug output destinations: serial console or log buffer          |
+------------------------------+------------------------------------------------------------------+

Commonly used definitions for these PCDs are listed here.

``PcdFixedDebugPrintErrorLevel`` definitions::

    #define DEBUG_INIT      0x00000001  // Initialization
    #define DEBUG_WARN      0x00000002  // Warnings
    #define DEBUG_INFO      0x00000040  // Informational debug messages
    #define DEBUG_VERBOSE   0x00400000  // Detailed debug messages that may
                                        // significantly impact boot performance
    #define DEBUG_ERROR     0x80000000  // Error


``PcdDebugPropertyMask`` definitions::

    #define DEBUG_PROPERTY_DEBUG_ASSERT_ENABLED       0x01
    #define DEBUG_PROPERTY_DEBUG_PRINT_ENABLED        0x02
    #define DEBUG_PROPERTY_DEBUG_CODE_ENABLED         0x04
    #define DEBUG_PROPERTY_CLEAR_MEMORY_ENABLED       0x08
    #define DEBUG_PROPERTY_ASSERT_BREAKPOINT_ENABLED  0x10
    #define DEBUG_PROPERTY_ASSERT_DEADLOOP_ENABLED    0x20


``PcdDebugOutputDeviceMask`` definitions::

    #define  DEBUG_OUTPUT_DEVICE_LOG_BUFFER     BIT0
    #define  DEBUG_OUTPUT_DEVICE_SERIAL_PORT    BIT1


For more details, see ``DebugLib.h`` and ``LoaderPlatformDataGuid.h``.

An example of minimum debug output from |SPN| release build on QEMU emulator::

    Intel Slim Bootloader
    SBID: SB_QEMU
    ISVN: 00001
    IVER: 000.00001.11095
    BOOT: BP0
    MODE: 0
    BoardID: 00
    Memory Init
    PCI Enum
    ACPI Init
    MP InitJump to payload

    Payload startup


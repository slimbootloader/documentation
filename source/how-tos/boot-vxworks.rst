.. _boot-vxworks:

Boot VxWorks
------------

This page provides instructions for creating a bootable VxWorks image in container format and setting up the boot option in |SPN|.

.. note:: See :ref:`gen-container-tool` for more details on container format.


**Step 1:** Download |CNT| and |CMU| to the same working directory to use the container tool.

.. |CNT| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader/blob/master/BootloaderCorePkg/Tools/GenContainer.py" target="_blank">GenContainer.py</a>

.. |CMU| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader/blob/master/BootloaderCorePkg/Tools/CommonUtility.py" target="_blank">CommonUtility.py</a>

**Step 2:** Get a VxWorks kernel.

 Obtain a VxWorks kernel binary. The binary should be in ELF format and multiboot compliant.

**Step 3:** Generate ``container.bin`` file

Run::

  GenContainer.py create -cl VXWK:<VxWorks kernel> -k SblKeys\OS1_TestKey_Pub_RSA2048_priv.pem -o container.bin

.. note:: SblKeys\\OS1_TestKey_Pub_RSA2048_priv.pem is given as an example key used for signing |SPN| OS container binaries.

Sample output messages::


    Container 'BOOT' was created successfully at:
    /home/user/container.bin


**Step 4:** Copy ``container.bin`` onto the intended boot media's boot partition.

Depending on the boot media being used, ``container.bin`` should be copied to the **root** directory on the boot device.

**Step 5:** Configure the boot option entry to load ``container.bin`` from the boot partition

Make sure the boot option is configured to the location of ``container.bin`` on the boot device. E.g., if ``container.bin`` is located on the first FAT32 partition on a USB, the boot option entry should look like the following::

  # !BSF SUBT:{OS_TMPL:0 :  0    :  0 :   5   :  0   :   0  :    0 :    0 :'container.bin' }

See :ref:`change-boot-options` for more details.


**Step 6:** Build, stitch, flash and boot

Follow :ref:`supported-hardware` to build a flashable image for the target platform.

.. note:: If the target boot option is not the first entry, enter |SPN| shell first to switch it to the first one.

Example boot messages::

    Idx|ImgType|DevType|DevNum|Flags|HwPart|FsType|SwPart|File/Lbaoffset
      0|      0|   USB |    0 |   0 |    0 |  FAT |    0 | container.bin
      1|      0|  NVME |    0 |  10 |    0 | EXT2 |    1 | /boot/sbl_os
      5|      0|  SATA |    0 |  10 |    0 | EXT2 |    1 | /boot/sbl_os


    ======== Try Booting with Boot Option 0 ========
    BootMediumPciBase(0x1400)
    Getting boot image from USB
    Init USB XHCI - Success
    Enumerate Bus - Success
    Found 2 USB devices on bus
    Use the 1st mass storage device
    Found 1 mass storage devices
    Try to find boot partition
    Partition type: MBR  (1 logical partitions)
    Find partition success
    Init File system
    Detected FAT on HwDev 0 Part 0
    BootSlot = 0x0
    File 'container.bin' size 8686432
    Get file 'container.bin' (size:0x848B60) success.
    LoadBootImage ImageType-0 Image
    ParseBootImage ImageType-0
    Registering container BOOT
    HASH verification for usage (0x00000800) with Hash Alg (0x1): Success
    SignType (0x1) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000800): Success
    HASH verification for usage (0x00000000) with Hash Alg (0x1): Success
    CONTAINER size = 0x848B60, image type = 0xF3, # of components = 2
    COMP:VXWK Success
    Unregister done - Success!
    One multiboot file in boot image file ....
    SetupBootImage ImageType-0
    Boot image is Multiboot format...
    Mb: LoadAddr=0x408000, LoadEnd=0xB55DA0 , BssEnd=0xBF4F20, Size=0x74DDA0

    Dump normal boot image info:

    Dump MB info @780D61C0:
    - Flags:                 1245
    - MemLower:              280 (640K)
    - MemUpper:           600C00 (6294528K)
    - BootDevicePart3:        0
    - BootDevicePart2:        0
    - BootDevicePart1:        0
    - BootDeviceDrive:        0
    - Cmdline addr:    77851000
    cmd = 'console=ttyS0,115200'
    - ModsCount:               0
    - ModsAddr:                0
    - ElfshdrNum:              0
    - ElfshdrSize:             0
    - ElfshdrAddr:             0
    - ElfshdrShndx:            0
    - MmapLength:            168
    - MmapAddr:         780D6810
      0: 0000000000000000--00000000000A0000   1
     18: 00000000000A0000--0000000000060000   2
     30: 0000000000100000--00000000780E0000   1
     48: 00000000781E0000--0000000000500000   2
     60: 00000000786E0000--0000000000068000   3
     78: 0000000078748000--0000000000008000   4
     90: 0000000078750000--0000000000500000   2
     A8: 0000000078C50000--00000000003B0000   2
     C0: 0000000079000000--0000000002000000   2
     D8: 000000007B000000--0000000000800000   2
     F0: 000000007B800000--0000000000800000   2
    108: 000000007C000000--0000000003C00000   2
    120: 00000000FED20000--0000000000060000   2
    138: 00000000FF66F000--0000000000991000   2
    150: 0000000100000000--0000000180400000   1
    - DrivesLength:            0
    - DrivesAddr:              0
    - ConfigTable:      00000000
    - LoaderName:       789E3088
      'Slim BootLoader'
    - ApmTable:         00000000
    - VbeControlInfo:  00000000
    - VbeModeInfo:     00000000
    - VbeInterfaceSeg:        0
    - VbeInterfaceOff:        0
    - VbeInterfaceLen:        0

    Dump multiboot boot state:
    - EntryPoint: 408000
    -        Eax: 2BADB002
    -        Ebx: 780D61C0
    -        Esi:    0
    -        Edi:    0

    Payload normal heap: 0x4000000 (0x8AF000 used)
    Payload reserved heap: 0x500000 (0x0 used)
    Payload stack: 0x20000 (0xA08 used)

    Jumping into ELF or Multiboot image entry point...
    ...
    Starting MB Kernel ...

    Target Name: vxTarget
    Instantiating /ata1a as rawFs,  device = 0x20001
    Instantiating /ata1c as rawFs,  device = 0x40001
    Instantiating /ata1d as rawFs,  device = 0x50001

     _________            _________
     \77777777\          /77777777/
      \77777777\        /77777777/
       \77777777\      /77777777/
        \77777777\    /77777777/
         \77777777\   \7777777/
          \77777777\   \77777/              VxWorks 7 SMP 64-bit
           \77777777\   \777/
            \77777777\   \7/     Core Kernel version: 3.1.2.1
             \77777777\   -      Build date: Jul  7 2020 10:30:42
              \77777777\
               \7777777/         Copyright Wind River Systems, Inc.
                \77777/   -                 1984-2020
                 \777/   /7\
                  \7/   /777\
                   -   -------

                       Board: x86 Processor (ACPI_BOOT_OP) SMP/SMT
                   CPU Count: 8
              OS Memory Size: ~8004MB
            ED&R Policy Mode: Deployed
         Debug Agent: Not started
             Stop Mode Agent: Not started

    ERROR: ipcom_drv_eth_init: drvname:gei, drvunit: 0

     Adding 13696 symbols for standalone.

    ->

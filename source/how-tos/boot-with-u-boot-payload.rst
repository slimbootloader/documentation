.. _boot-with-u-boot-payload:
.. _U-Boot: https://gitlab.denx.de/

Boot Linux with U-Boot Payload
------------------------------

|SPN| can boot Linux by using U-Boot_ Payload.

This page provides a step-by-step how to build SBL with U-Boot Payload.

Build Instruction for U-Boot
============================

Build U-Boot and obtain u-boot-dtb.bin::

    $ git clone https://gitlab.denx.de/u-boot/u-boot.git && cd u-boot
    $ make distclean
    $ make slimbootloader_defconfig
    $ make all

Prepare Slim Bootloader
=======================

1. Create PayloadBins directory in PayloadPkg::

    $ mkdir -p <Slim Bootloader Dir>/PayloadPkg/PayloadBins/

2. Copy u-boot-dtb.bin to PayloadBins directory::

    $ cp <U-Boot Dir>/u-boot-dtb.bin <Slim Bootloader Dir>/PayloadPkg/PayloadBins/u-boot-dtb.bin

Build Instruction for QEMU target
=================================

Slim Bootloader supports multiple payloads, and a board of Slim Bootloader
detects its target payload by PayloadId in board configuration.
The PayloadId can be any 4 Bytes value.

1. Update PayloadId. Let's use 'U-BT' as an example::

    $ vi Platform/QemuBoardPkg/CfgData/CfgDataExt_Brd1.dlt
    -GEN_CFG_DATA.PayloadId                     | 'AUTO'
    +GEN_CFG_DATA.PayloadId                     | 'U-BT'

2. Update payload text base. PAYLOAD_EXE_BASE must be the same as U-Boot
   CONFIG_SYS_TEXT_BASE in board/intel/slimbootloader/Kconfig.
   PAYLOAD_LOAD_HIGH must be 0::

    $ vi Platform/QemuBoardPkg/BoardConfig.py
    +               self.PAYLOAD_LOAD_HIGH    = 0
    +               self.PAYLOAD_EXE_BASE     = 0x00100000

3. Build QEMU target. Make sure u-boot-dtb.bin and U-BT PayloadId
   in build command. The output is Outputs/qemu/SlimBootloader.bin::

    $ python BuildLoader.py build qemu -p "OsLoader.efi:LLDR:Lz4;u-boot-dtb.bin:U-BT:Lzma"

4. Launch Slim Bootloader on QEMU.
   You should reach at U-Boot serial console::

    $ qemu-system-x86_64 -machine q35 -nographic -serial mon:stdio -pflash Outputs/qemu/SlimBootloader.bin

Test Linux booting on QEMU target
=================================

Let's use LeafHill (APL) Yocto image for testing.
Download it from http://downloads.yoctoproject.org/releases/yocto/yocto-2.0/machines/leafhill/.

1. Prepare Yocto hard disk image::

    $ wget http://downloads.yoctoproject.org/releases/yocto/yocto-2.0/machines/leafhill/leafhill-4.0-jethro-2.0.tar.bz2
    $ tar -xvf leafhill-4.0-jethro-2.0.tar.bz2
    $ ls -l leafhill-4.0-jethro-2.0/binary/core-image-sato-intel-corei7-64.hddimg

2. Launch Slim Bootloader on QEMU with disk image::

    $ qemu-system-x86_64 -machine q35 -nographic -serial mon:stdio -pflash Outputs/qemu/SlimBootloader.bin -drive id=mydrive,if=none,file=/path/to/core-image-sato-intel-corei7-64.hddimg,format=raw -device ide-hd,drive=mydrive

3. Update boot environment values on shell::

    => setenv bootfile vmlinuz
    => setenv bootdev scsi
    => boot

Build Instruction for LeafHill (APL) target
===========================================

LeafHill is using PCI UART2 device as a serial port.
For MEM32 serial port, CONFIG_SYS_NS16550_MEM32 needs to be enabled in U-Boot.

1. Enable CONFIG_SYS_NS16550_MEM32 in U-Boot::

    $ vi include/configs/slimbootloader.h
    +#define CONFIG_SYS_NS16550_MEM32
     #ifdef CONFIG_SYS_NS16550_MEM3

2. Build U-Boot::

    $ make disclean
    $ make slimbootloader_defconfig
    $ make all

3. Copy u-boot-dtb.bin to Slim Bootloader.
   Slim Bootloader looks for a payload from the specific location.
   Copy the build u-boot-dtb.bin to the expected location::

    $ mkdir -p <Slim Bootloader Dir>/PayloadPkg/PayloadBins/
    $ cp <U-Boot Dir>/u-boot-dtb.bin <Slim Bootloader Dir>/PayloadPkg/PayloadBins/u-boot-dtb.bin

4. Update PayloadId. Let's use 'U-BT' as an example::

    $ vi Platform/ApollolakeBoardPkg/CfgData/CfgData_Int_LeafHill.dlt
    -GEN_CFG_DATA.PayloadId                     | 'AUTO
    +GEN_CFG_DATA.PayloadId                     | 'U-BT'

5. Update payload text base.

* PAYLOAD_EXE_BASE must be the same as U-Boot CONFIG_SYS_TEXT_BASE
  in board/intel/slimbootloader/Kconfig.
* PAYLOAD_LOAD_HIGH must be 0::

    $ vi Platform/ApollolakeBoardPkg/BoardConfig.py
    +               self.PAYLOAD_LOAD_HIGH    = 0
    +               self.PAYLOAD_EXE_BASE     = 0x00100000

6. Build APL target. Make sure u-boot-dtb.bin and U-BT PayloadId
   in build command. The output is Outputs/apl/Stitch_Components.zip::

    $ python BuildLoader.py build apl -p "OsLoader.efi:LLDR:Lz4;u-boot-dtb.bin:U-BT:Lzma"

7. Stitch IFWI.

   Refer to Apollolake page in Slim Bootloader document site::

    $ python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -i <Existing IFWI> -s Outputs/apl/Stitch_Components.zip -o <Output IFWI>

8. Flash IFWI.

   Use DediProg to flash IFWI. You should reach at U-Boot serial console.


Build Instruction to use ELF U-Boot
===================================

1. Enable CONFIG_OF_EMBED::

    $ vi configs/slimbootloader_defconfig
    +CONFIG_OF_EMBED=y

2. Build U-Boot::

    $ make disclean
    $ make slimbootloader_defconfig
    $ make all
    $ strip u-boot (removing symbol for reduced size)

3. Do same steps as above

* Copy u-boot (ELF) to PayloadBins directory
* Update PayloadId 'U-BT' as above.
* No need to set PAYLOAD_LOAD_HIGH and PAYLOAD_EXE_BASE.
* Build Slim Bootloader. Use u-boot instead of u-boot-dtb.bin::

    $ python BuildLoader.py build <qemu or apl> -p "OsLoader.efi:LLDR:Lz4;u-boot:U-BT:Lzma"

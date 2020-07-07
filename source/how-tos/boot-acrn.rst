.. _boot-acrn:

Boot ACRN Hypervisor
------------------------

Step-by-Step guide to build a custom |SPN| to boot ACRN and provision eMMC on |UP2|.

.. note:: This is a lengthy but rewarding process. Please expect a few hours to complete this guide.

Prerequisites
^^^^^^^^^^^^^^^^^

Before you start, prepare the following items:

* Serial debug adapter for UART0 on |UP2| - Required to trigger fastboot and perform firmware update

* Micro USB cable (type A to microB)

* USB flash drive

* **RECOMMENDED:** A SPI programmer in case you brick |UP2| and need to restore factory BIOS. See |UP2_FLASHING| for details.

.. |UP2_FLASHING| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">BIOS chip flashing</a>


For more details on setting up the hardware, see :ref:`up2-board`.


Build |SPN| 
^^^^^^^^^^^^^^^^

This section describes how to build a custom |SPN| with fastboot support.

**Step 1:** Install tool chains and clone SBL source code from GitHub

  Run::

    sudo apt-get install -y build-essential iasl python uuid-dev nasm openssl gcc-multilib qemu
    git clone https://github.com/slimbootloader/slimbootloader.git
    cd slimbootloader
    git config --global user.email "email@example.com"
    git config --global user.name "your name"

  Compile |SPN| just to verify your setup is complete::

    python BuildLoader.py build apl


**Step 2:** Download additional required images and tools 

1. Download fastboot executable ``fastboot.elf`` from |FB| to |SPN| source directory

.. |FB| raw:: html

   <a href="https://github.com/intel/kernelflinger/raw/master/prebuilt/board/APL_UP2/fastboot.elf" target="_blank">here</a>

2. Download |UP2| BIOS from |BIOS_V4| and unzip as is in |SPN| source directory

.. |BIOS_V4| raw:: html

   <a href="https://downloads.up-community.org/download/up-squared-uefi-bios-v4-0/" target="_blank">here</a>

3. Download IAS script ``iasimage`` from |IAS| to |SPN| source directory

.. |IAS| raw:: html

   <a href="https://raw.githubusercontent.com/intel/iasimage/master/iasimage" target="_blank">here</a>

   Run as root the following commands::

     # apt-get install python3 python3-pip
     # pip3 install cryptography==2.2.2

**Step 3:** Generate IAS image containing ``fastboot.elf``

  Run::

    mkdir -p Platform/ApollolakeBoardPkg/SpiIasBin
    touch cmdline.txt
    chmod 755 ./iasimage
    ./iasimage create -o Platform/ApollolakeBoardPkg/SpiIasBin/iasimage1.bin -d ./BootloaderCorePkg/Tools/Keys/TestSigningPrivateKey.pem -i 0x40000 cmdline.txt fastboot.elf

``iasimage1.bin``
  The binary file will be added into |SPN| image during build process


  See :ref:`create-ias-boot-image` for additional details.


**Step 4:** Build and stitch

  Run::

    python BuildLoader.py build apl
    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -i UPA1AM40.bin -s Outputs/apl/Stitch_Components.zip -o sbl_up2_ifwi.bin -p 0xAA00000E -b bios.bin
    python BootloaderCorePkg/Tools/GenCapsuleFirmware.py -k $SBL_KEY_DIR/FirmwareUpdateTestKey_Priv_RSA2048.pem -o FwuImage.bin -b bios.bin

``sbl_up2_ifwi.bin``
  The binary file to be flashed by BIOS flash tool or SPI programmer

``FwuImage.bin``
  The binary file to be copied to USB flash drive to upgrade SBL from shell command


Flash |SPN|
^^^^^^^^^^^^^^^^

This section describes how to update |SPN| for the **first** time from UEFI BIOS shell interface.


**Step 1:** BIOS flash tool is included in the same BIOS package downloaded |BIOS_V4|

BIOS flash tool is named ``Fpt_xxx.efi`` inside the BIOS package.

**Step 2:** Copy **ALL** files from the downloaded BIOS package and ``sbl_up2_ifwi.bin`` to a USB flash drive formatted in FAT32

**Step 3:** Insert USB flash drive and boot |UP2|. Press **F7** during boot to enter UEFI shell

  Run::

    Shell> fs1:
    Shell> ls
    Shell> Fpt_3.1.50.2222.efi -f sbl_up2_ifwi.bin -y
    ...
    ...
    FPT Operation Successful.
    Shell>

The update process takes a few minutes.


Boot Up
^^^^^^^^

.. note:: |SPN| uses UART0 (CN16 connector) for early boot debug messages.

Connect serial adapter between |UP2| and the host. Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.

Power on |UP2| and observe the following debug messages from serial connection::

  BtGuard: VB : 0, MB : 0

  ============= Intel Slim Bootloader STAGE1A =============
  SBID: SB_APLI
  ISVN: 001
  IVER: 000.005.001.000.05486
  SVER: EDC112328CF3E414
  FDBG: BLD(D) FSP(R)
  FSPV: ID($APLFSP$) REV(01040301)
  Loader global data @ 0xFEF01D54
  Run  STAGE1A @ 0xFEF80000
  Load STAGE1B @ 0xFEF88000
  No BtGuard verification !

  ...

  ====================Os Loader====================


  Press any key within 1 second(s) to enter the command shell
  Boot options (in HEX):

  ...


Enter Fastboot Mode
^^^^^^^^^^^^^^^^^^^^

Currently the only method to enter fastboot mode is by user commands from |SPN| shell.

**Step 1:** Reset |UP2| and press any key in serial console to enter shell

**Step 2:** Type user command from shell to enter fastboot mode

Example debug messages (including user commands)::

    ====================Os Loader====================


    Press any key within 2 second(s) to enter the command shell

    Shell> boot
    Boot options (in HEX):

    Idx|ImgType|DevType|DevNum|Flags|HwPart|FsType|SwPart|File/Lbaoffset
      0|      0|   MMC |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      1|      0|   MMC |    0 |   0 |    0 |  RAW |    1 | 0x0       <-- ACRN boot option settings
      2|      0|  SATA |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      3|      0|   USB |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      4|      4|   MEM |    0 |   0 |    0 |  RAW |    0 | 0x0       <-- fastboot settings

    SubCommand:
      s   -- swap boot order by index
      a   -- modify all boot options one by one
      q   -- quit boot option change
      idx -- modify the boot option specified by idx (0 to 0x4)
    s
    Enter first index to swap (0x0 to 0x4)
    0
    Enter second index to swap (0x0 to 0x4)
    4
    Updated the Boot Option List
    Boot options (in HEX):

    Idx|ImgType|DevType|DevNum|Flags|HwPart|FsType|SwPart|File/Lbaoffset
      0|      4|   MEM |    0 |   0 |    0 |  RAW |    0 | 0x0
      1|      0|   MMC |    0 |   0 |    0 |  RAW |    1 | 0x0
      2|      0|  SATA |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      3|      0|   USB |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      4|      0|   MMC |    0 |   0 |    0 |  FAT |    0 | iasimage.bin


    Shell> exit
    Boot options (in HEX):

    Idx|ImgType|DevType|DevNum|Flags|HwPart|FsType|SwPart|File/Lbaoffset
      0|      4|   MEM |    0 |   0 |    0 |  RAW |    0 | 0x0
      1|      0|   MMC |    0 |   0 |    0 |  RAW |    1 | 0x0
      2|      0|  SATA |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      3|      0|   USB |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      4|      0|   MMC |    0 |   0 |    0 |  FAT |    0 | iasimage.bin

    BootMediumPciBase(0x1000000)
    Getting boot image from... MEM
    Try to find boot partition
    Part 00: 0xFF9DC000--0xFFB2C000, LBA count: 0x150000
    SPI BIOS region: (1 logical partitions)
    Find partition success
    BootSlot = 0x0
    Load image from SwPart (0x0), LbaAddr(0x0)
    HASH Verification Success! Component Type (6)
    RSA Verification Success!
    IAS image is properly signed/verified
    IAS size = 0x149404, file number: 2
    IAS Image Type = 0x4
    cmd Count = [0x0]
    Boot image is ELF format...
    and Image is Multiboot format
    SetupBootImage: Status = Success

    ...
    ...
    ...

    Starting MB Kernel ...

     abl cmd 00: console=ttyS0,115200
     abl cmd 00 length: 20
     abl cmd 01: fw_boottime=15230
     abl cmd 01 length: 17
    boot target: 1
    target=1
    Enter fastboot mode ...
    Start Send HECI Message: EndOfPost
    HECI sec_mode 00000000
    GetSeCMode successful
    GEN_END_OF_POST size is 4
    uefi_call_wrapper(SendwACK) =  0
    Group    =000000FF
    Command  =0000000C
    IsRespone=00000001
    Result   =00000000
    RequestedActions   =00000000
    USB for fastboot transport layer selected   <-- fastboot mode is active now!


**Step 4:** Verify fastboot connection

  Connect USB cable between host and |UP2| USB OTG port.

  Run (as root)::

    # apt-get install fastboot

    # fastboot devices
    HBG4a2428525f7  fastboot

    # fastboot getvar version-bootloader
    version-bootloader: fastboot-NonAndroid-1.0-userdebug


ACRN How-To
^^^^^^^^^^^

Now it's time to visit |ACRN_HOWTO| to build, flash and boot a complete ACRN Hypervisor with UOS on |UP2| board.

.. |ACRN_HOWTO| raw:: html

   <a href="https://projectacrn.github.io/latest/tutorials/using_sbl_on_up2.html" target="_blank">Project ACRN website</a>


Upgrade |SPN|
^^^^^^^^^^^^^^^^

Sometimes, you may need to update |SPN| firmware with newer versions on |UP2|.

.. warning:: It is highly recommended to have an SPI programmer in case |UP2| is bricked after firmware update.

**Step 1:** Copy ``FwuImage.bin`` onto USB flash drive formatted in FAT32

**Step 2:** Reset |UP2| and press any key to enter shell

  Run::

    Shell>

    Shell> fwupdate
    HECI SecMode 0
    Group    =00000020
    Command  =00000007
    IsRespone=00000001
    Result   =00000000
    ...
    ...

The system should start updating and reset itself **a few times**. If the update is successful, the system should boot into ACRN again.

To confirm the |SPN| is updated correctly, take notes of the version information from serial debug messages **before** and **after** the update::

  BtGuard: VB : 0, MB : 0

  ============= Intel Slim Bootloader STAGE1A =============
  SBID: SB_APLI
  ISVN: 001
  IVER: 000.005.001.000.05482 <-- Last part (05482) is a unique time stamp from build
  SVER: C815BBFB25461C98      <-- GIT commit SHA1
  FDBG: BLD(D) FSP(R)
  FSPV: ID($APLFSP$) REV(01040301)
  Loader global data @ 0xFEF01D54
  Run  STAGE1A @ 0xFEF80000
  Load STAGE1B @ 0xFEF88000
  No BtGuard verification !



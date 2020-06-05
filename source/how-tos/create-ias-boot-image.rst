.. _create-ias-boot-image:

Create IAS Boot Image
----------------------

.. attention:: IAS image format is deprecated; container format is preferred. See :ref:`create-container-boot-image` for more details.

This page provides instructions to create a bootable Linux kernel image in IAS format and setup boot partition in |SPN| to boot from it.


The following step-by-step instructions is an example to boot Yocto kernel using IAS image format on |UP2|.


**Step 1:** Download and install open source IAS tool from |IAS|

.. |IAS| raw:: html

   <a href="https://github.com/intel/iasimage" target="_blank">here</a>


**Step 2:** Get kernel and associated files from target Yocto disk image.

 1. Locate and save a copy of vmlinuz (e.g. ``vmlinuz``), initramfs (``initrd``)

 2. Create ``cmdline.txt`` with kernel command line string. There are different ways to extract kernel command line from a booted system. Examples includes ``grub.cfg``, ``/proc/cmdline`` or via ``dmesg | grep 'Command line'``. If the command line is empty, create an empty file.

**Step 3:** Generate ``iasimage.bin`` file

Run::

  iasimage -i 0x30300 -o iasimage.bin -d <RSA_private_key> <cmdline.txt> <vmlinuz> <initrd>

    <RSA_private_key>: hash of the public key should be included in |SPN| Key Manifest and HASH_USAGE should be set to 'PUBKEY_OS' during |SPN| build.

Sample output messages::

    Creating ias-image with 3 files
    Detected image type is (0x30000) - Multi-file boot image
      cmd.null.txt (0 Bytes)
      vmlinuz (6.6 MiB)
      initrd (7.3 MiB)
    File 1 size 0 bytes
    File 2 size 6902016 bytes
    File 3 size 7644383 bytes
    Calculating Checksum... Ok
    Signing... Ok
    Writing... Ok


**Step 4:** Copy ``iasimage.bin`` onto the first boot partition on |UP2|.

Depending whether you are booting from eMMC or USB, ``iasimage.bin`` should be copied to the **root** directory on the boot device.

**Step 5:** Configure boot option entry to load ``iasimage.bin`` from the boot partition

Make sure the boot option is configured to the location of ``iasimage.bin`` on the boot device. E.g., if ``iasimage.bin`` is located on the first boot FAT32 partition on USB, the boot option entry should look like the following::

  # !BSF SUBT:{OS_TMPL:3 :  0    :  0 :   5   :  0   :   0  :    0 :    0 :'iasimage.bin' :       0 :      0 :     0         :     0   :  0     :     0         :     8   :   0    }

See :ref:`change-boot-options` for more details.


**Step 6:** Build, stitch, flash and boot

Follow :ref:`supported-hardware` to build a flashable image for the target platform.

.. note:: If the target boot option is not the first entry, enter |SPN| shell first to switch it to the first one.

Example boot messages::

    ...
    <Switch boot option to boot USB ...>
    ...

    Shell> exit
    Boot options (in HEX):

    Idx|ImgType|DevType|DevNum|Flags|HwPart|FsType|SwPart|File/Lbaoffset
      0|      0|   USB |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      1|      0|   MMC |    0 |   0 |    0 | AUTO |    1 | iasimage.bin
      2|      0|  SATA |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      3|      0|   MMC |    0 |   0 |    0 |  FAT |    0 | iasimage.bin
      4|      4|   MEM |    0 |   0 |    0 |  RAW |    0 | 0x0

    BootMediumPciBase(0x1500)
    Getting boot image from... USB
    Init USB XHCI - Success
    Enumerate Bus - Success
    Found 3 USB devices on bus
    Found mass storage on device 2
    Try to find boot partition
    Partition type: MBR  (1 logical partitions)
    Find partition success
    BootSlot = 0x0
    Init File system
    Detected FAT on HwDev 0 Part 0
    Get file 'iasimage.bin' (size:0xE42504) success.
    HASH Verification Success! Component Type (6)
    RSA Verification Success!
    IAS image is properly signed/verified
    IAS size = 0xE42504, file number: 3
    IAS Image Type = 0x3
    Assume BzImage...
    Setup bzImage boot parameters ...
    Found bzimage Signature
    Src=0x7886F6A8 Dest=0x100000 KernelSize=7288512
    SetupBootImage: Status = Success

    Dump normal boot image info:


    ============ KERNEL SETUP ============
    SetupSectorss: 0x22
    RootFlags: 0x1
    SysSize: 0x6F36C

    ...






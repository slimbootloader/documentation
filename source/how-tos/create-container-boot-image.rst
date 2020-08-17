.. _create-container-boot-image:

Create Container Boot Image
---------------------------

This page provides instructions for creating a bootable Linux kernel image in container format and setup boot partition in |SPN| to boot from it.

.. note:: See :ref:`gen-container-tool` for more details on container format.

The following step-by-step instructions is an example to boot Yocto kernel using container image format on |UP2|.

.. important:: SBL Linux boot image containers typically include the kernel, kernel params and initramfs. The kernel then will mount the root file system from the boot media. There may be additional requirements in terms of configuration and layout for the kernel to locate and mount the root file system. If your boot image has some partition layout requirements, file/file-path dependencies, etc., you still need to adhere to those requirements when using container boot.

**Step 1:** Download |CNT| and |CMU| to the same working directory to use the container tool.

.. |CNT| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader/blob/master/BootloaderCorePkg/Tools/GenContainer.py" target="_blank">GenContainer.py</a>

.. |CMU| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader/blob/master/BootloaderCorePkg/Tools/CommonUtility.py" target="_blank">CommonUtility.py</a>

**Step 2:** Get kernel and associated files from target Yocto disk image.

 1. Locate and save a copy of vmlinuz (e.g. ``vmlinuz``), initramfs (``initrd``)

 2. Create ``cmdline.txt`` with kernel command line string. There are different ways to extract kernel command line from a booted system. Examples includes ``grub.cfg``, ``/proc/cmdline`` or via ``dmesg | grep 'Command line'``. If the command line is empty, create an empty file.

**Step 3:** Generate ``container.bin`` file

Run::

  GenContainer.py create -cl CMDL:<cmdline.txt> KRNL:<vmlinuz> INRD:<initrd> -k <RSA_private_key> -t CLASSIC -o container.bin

     <RSA_private_key>: KEY_ID or RSA 2048/3072 private key path in PEM format to sign image. Use '_KEY_ID_CONTAINER' for KEY_ID type.
     <RSA_private_key>: hash of the public key should be included in |SPN| Key Manifest and HASH_USAGE should be set to 'PUBKEY_OS' during |SPN| build

Sample output messages::


    Container 'BOOT' was created successfully at:
    /home/user/container.bin


**Step 4:** Copy ``container.bin`` onto the first boot partition on |UP2|.

Depending whether you are booting from eMMC or USB, ``container.bin`` should be copied to the **root** directory on the boot device.

**Step 5:** Configure boot option entry to load ``container.bin`` from the boot partition

Make sure the boot option is configured to the location of ``container.bin`` on the boot device. E.g., if ``container.bin`` is located on the first boot FAT32 partition on USB, the boot option entry should look like the following::

  # !BSF SUBT:{OS_TMPL:3 :  0    :  0 :   5   :  0   :   0  :    0 :    0 :'container.bin' :       0 :      0 :     0         :     0   :  0     :     0         :     8   :   0    }

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
      0|      0|   USB |    0 |   0 |    0 | EXT2 |    1 | container.bin
      1|      0|  SATA |    0 |   0 |    1 | EXT2 |    1 | container.bin
      2|      0|   MMC |    0 |   0 |    0 | EXT2 |    1 | container.bin
      3|      0|  NVME |    0 |   0 |    0 | EXT2 |    1 | container.bin


    ======== Try Booting with Boot Option 0 ========
    BootMediumPciBase(0x1500)
    Getting boot image from USB
    Init USB XHCI - Success
    Enumerate Bus - Success
    Found 2 USB devices on bus
    Found mass storage on device 1
    Try to find boot partition
    Find partition success
    Init File system
    Detected FAT on StartBlock 270336 Part 0
    BootSlot = 0x0
    File 'container.bin' size 17244208
    Get file 'container.bin' (size:0x1072030) success.
    LoadBootImage ImageType-0 Image
    ParseBootImage ImageType-0
    Registering container BOOT
    HASH verification for usage (0x00000800) with Hash Alg (0x1): Success
    SignType (0x1) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000800): Success
    CONTAINER size = 0x1072030, image type = 0xF3, # of components = 4
    COMP:CMDL Success
    COMP:KRNL Success
    COMP:INRD Success
    Unregister done - Success!
    SetupBootImage ImageType-0
    Assume BzImage...
    Found bzimage Signature

    Dump normal boot image info:


    ============ KERNEL SETUP ============
    SetupSectorss: 0x20
    RootFlags: 0x1
    SysSize: 0x106D2A

    ...






.. _update-firmware:

Update Firmware
----------------

Creating firmware update capsule image requires the following steps:

# Build |SPN| for |UP2|::

  python BuildLoader.py build apl

#. Run stitch tool to create a |SPN| capsule payload from IFWI image

  For example, the following command creates ``sbl.bios.bin`` from |SPN| image and factory BIOS ``UPA1AM33.bin`` for |UP2| board::

    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -b sbl.bios.bin -i UPA1AM33.bin -s Outputs/apl/Stitch_Components.zip -o up2_sbl.bin -p 0xAA00000E

.. note:: ``-b`` option is important for creating the capsule image.

  See :ref:`stitch-tool` for more details on stitching.



#. Run capsule tool to generate capsule image

  Capsule tool (``GenCapsuleFirmware.py``) creates a capsule image that can be processed by |SPN| in firmware update flow.

  Capsule tool is capable of incorporating multiple firmware images into single capsule binary. Each firmware is identified and included in the capsule image using a GUID.
  Known GUIDs are included in the capsule generation tool, please refer to the note below for more details.

    usage: GenCapsuleFirmware.py [-h] -p BIOS <BIOS_IMAGE> -p <GUID> <FW IMAGE BINARY 1>.....-p <GUID> <FW IMAGE BINARY n> -k PRIVKEY -o NEWIMAGE [-q]

    optional arguments:
      -h, --help            show this help message and exit
      -p  <GUID> <Payload Image>, 
                            Payload image that goes into firmware update capsule
      -k PRIVKEY, --priv_key PRIVKEY
                            Private RSA 2048 key in PEM format to sign image
      -o NEWIMAGE, --output NEWIMAGE
                            Output file for signed image
      -q, --quiet           without output messages or temp files

  For example, the following command generates a capsule image (``FwuImage.bin``) containing an IFWI image (``sbl.bios.bin``), CSME image (``csme.bin``), CSME Firmware Update Driver (``csme_fw_update_driver.bin``) and firmware image (``fwimage.bin``) signed by key ``TestSigningPrivateKey.pem``::

    $ python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS sbl.bios.bin -p CSME  csme.bin -p CSMD csme_fw_update_driver.bin -p fwimage.bin -k ./BootloaderCorePkg/Tools/Keys/TestSigningPrivateKey.pem -o FwuImage.bin
    Successfully signed Bootloader image!
    $

.. note:: For user convenience GUID's for following firmwares are included in the capsule generation tool and these firmwares can be included in the capsule image by using known string in place of GUID in the command line.

        +-----------------------------+------------------------------------+
        | **String for Known Guid**   |         **Firmware**               |
        +-----------------------------+------------------------------------+
        |         **BIOS**            |       Slim Bootloader              |
        +-----------------------------+------------------------------------+
        |         **CSME**            |       CSME update binary           |
        +-----------------------------+------------------------------------+
        |         **CSMD**            |       CSME update driver           |
        +-----------------------------+------------------------------------+
        |         **CFGD**            |       Configuration data binary    |
        +-----------------------------+------------------------------------+

.. note:: In a real OTA scenario, OS shall *deposit* an authenticated capsule image in the boot device from network. During firmware update, the capsule is loaded and updated in SPI flash.


.. _trigger-update-from-shell:

Trigger Update From Shell
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

During development, one can use shell command to manually test firmware update without relying on full OTA support in OS.

1. Copy ``FwuImage.bin`` into root directory on FAT partition of a USB key

2. Boot and press any key to enter |SPN| shell

3. Type command ``fwupdate`` from shell

   Observe |SPN| resets the platform and performs update flow. It resets *multiple* times to complete the update process.

   A sample boot messages from console::

    Shell> fwupdate
    HECI SecMode 0
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    BootPolicy : 0x00000010
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Jump to payload
    ...
    Starting Firmware Update
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x787AF000, CapsuleSize: 0xEFE248
    HASH Verification Success! Component Type (5)
    RSA Verification Success!
    The new BOOTLOADER image passed verification
    ...
    HECI/CSE ready for update
    Updating 0x77F000, Size:0x10000
    ................  Finished     0%
    Updating 0x78F000, Size:0x10000
    ................  Finished     1%
    ...
    Updating 0xEDF000, Size:0x10000
    ................  Finished    99%
    Updating 0xEEF000, Size:0xE000
    ..............  Finished    99%
    .Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP1
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    BootPolicy : 0x00000010
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x787AE000, CapsuleSize: 0xEFE248
    HASH Verification Success! Component Type (5)
    RSA Verification Success!
    The new BOOTLOADER image passed verification
    ...
    HECI/CSE prepare for update failed
    Updating 0x0, Size:0x10000
    x...............  Finished     0%
    Updating 0x10000, Size:0x10000
    ................  Finished     1%
    Updating 0x20000, Size:0x10000
    ................  Finished    99%
    Updating 0x770000, Size:0xF000
    ...............  Finished    99%
    .Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Firmware update Done! clear CSE flag to normal boot mode.
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    ==================== OS Loader ====================

    Starting Kernel ...

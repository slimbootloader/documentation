.. _elkhartlake-lake-crb:

Elkhart Lake CRB Board
-----------------------

.. note:: Intel Atom x6000E Series processor is formally known as |EHL|.

Supported Boards
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports **EHL CRB** platform.


Building
^^^^^^^^^^

To build |SPN| for |EHL| platform::

    python BuildLoader.py build ehl

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

1. Gather |EHL| IFWI firmware image

  Users can either download the full IFWI image if the IFWI image release is available, or read the exising IFWI image on the board using SPI programmer.
  This image contains additional firmware ingredients that are required to boot on |EHL|.

.. note::
  ``StitchLoader.py`` currently only supports stitching with boot guard feature **disabled**.
  To stitch with Boot Guard enabled, please use ``StitchIfwi.py``.


2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/ElkhartlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/ehl/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME>

    where -i = Input file, -o = Output file.

For example, stitching |SPN| IFWI image ``sbl_ehl_ifwi.bin`` from |EHL| firmware images downloaded::

    python Platform/ElkhartlakeBoardPkg/Script/StitchLoader.py -i xxxx.bin -s Outputs/ehl/SlimBootloader.bin -o sbl_ehl_ifwi.bin

For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_ehl_ifwi.bin`` to the target board using DediProg SF100 or SF600 programmer.


.. note:: Please check the alignment/polarity when connecting Dediprog to the board. Please power off the board before connecting the Dediprog.
.. note:: Please set the dediprog  to flash the ifwi binary from offset 0

.. note:: The connector labelled **J3D4** on the target board is for DediProg.
.. note:: Please disconnect Deidprog before powering up the board again.


Slimbootloader binary for capsule image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to the build command above or :ref:`build-tool`.

slimbootloader binary generated in ``outputs\ehl\slimbootloader.bin`` can be used for generating capsule image


Capsule image for |EHL|
^^^^^^^^^^^^^^^^^^^^^^^^^

To generate capsule image for |EHL| platform::

    python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/ehl/SlimBootloader.bin -k <Keys> -o FwuImage.bin

For more details on generating capsule image, please refer :ref:`generate-capsule`.


Triggering Firmware Update
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to :ref:`firmware-update` on how to trigger firmware update flow.
Below is an example:

To trigger firmware update in |SPN| shell:

1. Copy ``FwuImage.bin`` into root directory on FAT partition of a USB key

2. Boot and press any key to enter |SPN| shell

3. Type command ``fwupdate`` from shell

   Observe |SPN| resets the platform and performs update flow. It resets *multiple* times to complete the update process.

   A sample boot messages from console::

    Shell> fwupdate
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 18
    BoardID: 0x05
    PlatformName: EHL_CRB
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Jump to payload
    ...
    Starting Firmware Update
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x758B4010, CapsuleSize: 0x9E328C
    HASH verification for usage (0x00000400) with Hash Alg (0x1): Success
    SignType (0x2) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000400): Success
    Set next FWU state: 0x7F
    Get current FWU state: 0x7F
    ...
    Updating 0x008F3000, Size:0x10000
    ................
    Finished     1%
    ...
    Finished    99%
    Updating 0x004F1000, Size:0x0E000
    ...............
    Finished   100%
    Set next FWU state: 0x7D
    Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP1
    MODE: 18
    BoardID: 0x05
    PlatformName: EHL_CRB
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x758B4010, CapsuleSize: 0x9E328C
    HASH verification for usage (0x00000400) with Hash Alg (0x1): Success
    SignType (0x2) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000400): Success
    Get current FWU state: 0x7D
    ...
    Updating 0x008F3000, Size:0x10000
    ................
    Finished     1%
    ...
    Finished    99%
    Updating 0x004F1000, Size:0x0E000
    ...............
    Finished   100%
    Set next FWU state: 0x7C
    Firmware Update status updated to reserved region
    Set next FWU state: 0x77
    Reset required to proceed with the firmware update.
    ...
    ==================== OS Loader ====================

    Starting Kernel ...


Debug UART
^^^^^^^^^^^

For |EHL|, serial port connector is labelled **J5J1** on board

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.


Booting Yocto Linux
^^^^^^^^^^^^^^^^^^^^^

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

1. Download Yocto Linux
2. Create bootable USB key. For example: In Windows, Rufus can be used. In Linux, etcher app can be used.
3. Boot the bootable OS image from USB key on the board.


Board ID Assignments
^^^^^^^^^^^^^^^^^^^^^

EHL CRB is assigned with a unique platform ID

  +---------------------------+---------------+
  |           Board           |  Platform ID  |
  +---------------------------+---------------+
  |           |EHL|           |     0x05      |
  +---------------------------+---------------+

See :ref:`dynamic-platform-id` for more details.

To customize board configurations in ``*.dlt`` file, make sure to specify ``PlatformId`` to the corresponding values for the board.

See :ref:`configuration-tool` for more details.

Latest Milestone Release
^^^^^^^^^^^^^^^^^^^^^^^^^

**EHL MR1**

Commit ID: 748aeb0eaf50918926e11466960d79ca3333a4f1


.. _tiger-lake-rvp:

Tiger Lake RVP Board
-----------------------

.. note:: 11th Generation Intel® Core Processor is formally known as |TGL| platform.

Supported Boards
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports **TGL UP3 DDR4 and TGL UP3 DDRLP4** platforms.


Building
^^^^^^^^^^

To build |SPN| for |TGL| platform::

    python BuildLoader.py build tgl

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

1. Gather |TGL| IFWI firmware image

  Users can either download the full IFWI image if the IFWI image release is available, or read the exising IFWI image on the board using SPI programmer.
  This image contains additional firmware ingredients that are required to boot on |TGL|.

.. note::
  ``StitchLoader.py`` currently only supports stitching with boot guard feature **disabled**.
  To stitch with Boot Guard enabled, please use ``StitchIfwi.py``.


2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/TigerlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/tgl/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME>

    where -i = Input file, -o = Output file.

For example, stitching |SPN| IFWI image ``sbl_tgl_ifwi.bin`` from |TGL| firmware images downloaded::

    python Platform/TigerlakeBoardPkg/Script/StitchLoader.py -i xxxx.bin -s Outputs/tgl/SlimBootloader.bin -o sbl_tgl_ifwi.bin

For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_tgl_ifwi.bin`` to the target board using DediProg SF100 or SF600 programmer.


.. note:: Please check the alignment/polarity when connecting Dediprog to the board. Please power off the board before connecting the Dediprog.
.. note:: Please set the dediprog  to flash the ifwi binary from offset 0

.. note:: The connector labelled **J4H2** on the target board is for DediProg.
.. note:: Please disconnect Deidprog before powering up the board again.


Slimbootloader binary for capsule image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to the build command above or :ref:`build-tool`.

slimbootloader binary generated in ``outputs\tgl\slimbootloader.bin`` can be used for generating capsule image


Capsule image for |TGL|
^^^^^^^^^^^^^^^^^^^^^^^^^

To generate capsule image for |TGL| platform::

    python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/tgl/SlimBootloader.bin -k <Keys> -o FwuImage.bin

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
    BoardID: 0x01
    PlatformName: TGLU_DDR
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Jump to payload
    ...
    Starting Firmware Update
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x7770A010, CapsuleSize: 0x99128C
    HASH verification for usage (0x00000400) with Hash Alg (0x1): Success
    SignType (0x2) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000400): Success
    Set next FWU state: 0x7F
    Get current FWU state: 0x7F
    ...
    Updating 0x00891000, Size:0x10000
    ................
    Finished     1%
    ...
    Finished    99%
    Updating 0x002B1000, Size:0x0A000
    ...............
    Finished   100%
    Set next FWU state: 0x7E
    Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP1
    MODE: 18
    BoardID: 0x01
    PlatformName: TGLU_DDR
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x7770A010, CapsuleSize: 0x99128C
    HASH verification for usage (0x00000400) with Hash Alg (0x1): Success
    SignType (0x2) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000400): Success
    Get current FWU state: 0x7E
    ...
    Updating 0x00891000, Size:0x10000
    ................
    Finished     1%
    ...
    Finished    99%
    Updating 0x002B1000, Size:0x0A000
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

For |TGL|, serial port connector is labelled **J4A1** on board

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.


Booting Yocto Linux
^^^^^^^^^^^^^^^^^^^^^

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

1. Download Yocto Linux
2. Create bootable USB key. For example: In Windows, Rufus can be used. In Linux, etcher app can be used.
3. Boot the bootable OS image from USB key on the board.


Board ID Assignments
^^^^^^^^^^^^^^^^^^^^^

Each TGL UP3 RVP board is assigned with a unique platform ID

  +---------------------------+---------------+
  |           Board           |  Platform ID  |
  +---------------------------+---------------+
  |          |DDR4|           |     0x01      |
  +---------------------------+---------------+
  |         |DDRLP4|          |     0x03      |
  +---------------------------+---------------+

See :ref:`dynamic-platform-id` for more details.

To customize board configurations in ``*.dlt`` file, make sure to specify ``PlatformId`` to the corresponding values for the board.

See :ref:`configuration-tool` for more details.



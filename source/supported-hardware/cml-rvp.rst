.. _comet-lake-rvp:

Comet Lake RVP Board
-----------------------

.. note:: 10th Generation Intel® Core Processor is formally known as |CML| S.

Supported Boards
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports **CML S RVP with PCH H, CML S RVP with PCH H420E and CML S RVP with PCH V** platforms.


Building
^^^^^^^^^^

To build |SPN| for |CML| platform::

    for PCH H and PCH H420E:
    python BuildLoader.py build cml

    for PCH V:
    python BuildLoader.py build cmlv

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

1. Gather |CML| IFWI firmware image

  Users can either download the full IFWI image if the IFWI image release is available, or read the exising IFWI image on the board using SPI programmer.
  This image contains additional firmware ingredients that are required to boot on |CML|.

.. note::
  ``StitchLoader.py`` currently only supports stitching with boot guard feature **disabled**.
  To stitch with Boot Guard enabled, please use ``StitchIfwi.py``.


2. Stitch |SPN| images into downloaded BIOS image::

    for PCH H and PCH H420E:
    python Platform/CometlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/cml/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME>

    for PCH V:
    python Platform/CometlakevBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/cmlv/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME>

    where -i = Input file, -o = Output file.

For example, stitching |SPN| IFWI image ``sbl_cml_ifwi.bin`` from |CMLH| firmware images downloaded::

    python Platform/CometlakeBoardPkg/Script/StitchLoader.py -i xxxx.bin -s Outputs/cml/SlimBootloader.bin -o sbl_cml_ifwi.bin

For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_cml_ifwi.bin`` or ``sbl_cmlv_ifwi.bin`` to the target board using DediProg SF100 or SF600 programmer.


.. note:: Please check the alignment/polarity when connecting Dediprog to the board. Please power off the board before connecting the Dediprog.
.. note:: Please set the dediprog  to flash the ifwi binary from offset 0

.. note:: The connector labelled **J7G1** on the target board is for DediProg.
.. note:: Please disconnect Deidprog before powering up the board again.


Slimbootloader binary for capsule image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to the build command above or :ref:`build-tool`.

slimbootloader binary generated in ``outputs\cml\slimbootloader.bin`` or ``outputs\cmlv\slimbootloader.bin`` can be used for generating capsule image


Capsule image for |CML|
^^^^^^^^^^^^^^^^^^^^^^^^^

To generate capsule image for |CML| platform::

    for PCH H and PCH H420E:
    python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/cml/SlimBootloader.bin -k <Keys> -o FwuImage.bin

    for PCH V:
    python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/cmlv/SlimBootloader.bin -k <Keys> -o FwuImage.bin

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
    HECI SecMode 0
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP1
    MODE: 0
    BoardID: 0x11
    PlatformName: CML_S
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Jump to payload
    ...
    Starting Firmware Update
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x8EABA010, CapsuleSize: 0x83028C
    HASH verification for usage (0x00000400) with Hash Alg (0x1): Success
    SignType (0x1) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000400): Success
    Set next FWU state: 0x7F
    Get current FWU state: 0x7F
    ...
    Updating 0x007F0000, Size:0x10000
    ................
    Finished     1%
    ...
    Finished    98%
    Updating 0x002A1000, Size:0x0F000
    ...............
    Finished   100%
    Set next FWU state: 0x7D
    Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 18
    BoardID: 0x11
    PlatformName: CML_S
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x8EABA010, CapsuleSize: 0x83028C
    HASH verification for usage (0x00000400) with Hash Alg (0x1): Success
    SignType (0x1) SignSize (0x100)  SignHashAlg (0x1)
    RSA verification for usage (0x00000400): Success
    Get current FWU state: 0x7D
    ...
    Updating 0x007F0000, Size:0x10000
    ................
    Finished     1%
    ...
    Finished    98%
    Updating 0x002A1000, Size:0x0F000
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

For |CML|, serial port connector is labelled **J9B7** on board

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.


Booting Yocto Linux
^^^^^^^^^^^^^^^^^^^^^

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

1. Download Yocto Linux
2. Create bootable USB key. For example: In Windows, Rufus can be used. In Linux, etcher app can be used.
3. Boot the bootable OS image from USB key on the board.


Board ID Assignments
^^^^^^^^^^^^^^^^^^^^^

CML S RVP with different PCH is assigned with a unique platform ID

  +---------------------------+---------------+
  |           Board           |  Platform ID  |
  +---------------------------+---------------+
  |          |CMLH|           |     0x11      |
  +---------------------------+---------------+
  |        |CMLH420E|         |     0x11      |
  +---------------------------+---------------+
  |          |CMLV|           |     0x15      |
  +---------------------------+---------------+

See :ref:`dynamic-platform-id` for more details.

To customize board configurations in ``*.dlt`` file, make sure to specify ``PlatformId`` to the corresponding values for the board.

See :ref:`configuration-tool` for more details.



.. _apollo-lake-crb:

Apollo Lake CRB Boards
-----------------------

.. note:: Intel Atom® Processor E3900 is formally known as |APL|.

Supported Boards
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports **Leaf Hill, Juniper Hill and Oxbow Hill** board variations of |APL|. 

  

Building
^^^^^^^^^^

To build |SPN| for |APL| platform::

    python BuildLoader.py build apl

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

1. Download |APL| `firmware image <https://firmware.intel.com/sites/default/files/leafhill-0.70-firmwareimages.zip>`_.

  This image contains additional firmware ingredients that are required to boot on |APL|.

.. note::
  ``StitchLoader.py`` currently only supports stitching with boot guard feature **disabled**. 
  Unzip the firmware images that contains two |APL| firmware images, one is Debug version and one is Release version, both of them can be used for stitch SBL IFWI. 


2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/apl/Stitch_Components.zip -o <SBL_IFWI_IMAGE_NAME>

    where -i = Input file, -o = Output file.

For example, stitching |SPN| IFWI image ``sbl_lfh_ifwi.bin`` from |APL| firmware images downloaded::

    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -i LEAFHILD.X64.0070.R01.1805070352.bin -s Outputs/apl/Stitch_Components.zip -o sbl_lfh_ifwi.bin


For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_lfh_ifwi.bin`` to the target board using DediProg SF100 or SF600 programmer.


.. note:: Please check the alignment/polarity when connecting Dediprog to the board. Please power off the board before connecting the Dediprog.

.. note:: The connector labelled **SPI TPM - J5D1** on the target board is for DediProg. 

.. note:: Please disconnect Deidprog before powering up the board again.


Slimbootloader binary for capsule image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Creating slimbootloader binary for capsule image requires the following steps:

Build |SPN| for |APL|::

  python BuildLoader.py build apl

Run stitch tool to create a |SPN| image from IFWI binary

  For example, the following command creates ``sbl.bios.bin`` from |SPN| image and |APL| firmware images downloaded::

    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -b sbl.bios.bin -i LEAFHILD.X64.0070.R01.1805070352.bin -s Outputs/apl/Stitch_Components.zip -o sbl_lfh_ifwi.bin

.. note:: ``-b`` option is important for creating the slimbootloader capsule image.


Triggering Firmware Update
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sample implementation of trigerring firmware update is explained below

|SPN| for |APL| uses BIT16 of PMC I/O register (Scratchpad for sharing data between BIOS and PMC Firmware (BIOS_SCRATCHPAD) - Offset 1090h) to trigger firmware update. When BIT16 is set, |SPN| will set the boot mode to FLASH_UPDATE.

please refer to IsFirmwareUpdate() function called in ``Platform\ApollolakeBoardPkg\Library\Stage1BBoardInitLib\Stage1BBoardInitLib.c`` to understand how |SPN| will detect firmware update mode.


Debug UART
^^^^^^^^^^^

For |APL|, LPSS UART **Port 2** is the debug UART configured in |SPN|. 

The |APL| have a FTDI chip for serial to USB connection. Please connect the **micro USB connector** next to the power button on the target board to a host and a 
terminal software to enable debug console from |SPN|.


Booting Yocto Linux
^^^^^^^^^^^^^^^^^^^^^

See :ref:`boot-yocto-usb` for more details.

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.



Board ID Assignments
^^^^^^^^^^^^^^^^^^^^^

Each |APL| CRB board is assigned a unique platform ID by reading a set of GPIO pins (25, 26 and 30).

  +-----------------+---------------+
  |      Board      |  Platform ID  |
  +-----------------+---------------+
  |   Oxbow Hill    |       6       |
  +-----------------+---------------+
  |    Leaf Hill    |       7       |
  +-----------------+---------------+
  |  Juniper Hill   |       8       |
  +-----------------+---------------+


See :ref:`dynamic-platform-id` for more details.

To customize board configurations in ``*.dlt`` file, make sure to specify ``PlatformId`` to the corresponding values for the board.

See :ref:`configuration-tool` for more details.

.. _apollo-lake-crb:

Apollo Lake CRB Boards
-----------------------

.. note:: Intel Atom® Processor E3900 is formally known as |APL|.

Board ID Assignments
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports the following board variations based on |APL|. Each board is assigned a unique platform ID by reading a set of GPIO pins (25, 26 and 30).

  +-----------------+---------------+
  |      Board      |  Platform ID  |
  +-----------------+---------------+
  |   Oxbox Hill    |       6       |
  +-----------------+---------------+
  |    Leaf Hill    |       7       |
  +-----------------+---------------+
  |  Juniper Hill   |       8       |
  +-----------------+---------------+


See :ref:`dynamic-platform-id` for more details.

To customize board configurations in ``*.dlt`` file, make sure to specify ``PlatformId`` to the corresponding values for the board.

See :ref:`configuration-tool` for more details.



Debug UART
^^^^^^^^^^^

For |APL|, LPSS UART **Port 2** is the debug UART configured in |SPN|.


Building
^^^^^^^^^^

To build::

    python BuildLoader.py build apl

The output images are generated under ``Outputs`` directory.

See :ref:`getting-started` on how to building |SPN|.


Stitching
^^^^^^^^^^

1. Download |APL| `firmware image <https://firmware.intel.com/sites/default/files/leafhill-0.70-firmwareimages.zip>`_.

  This image contains additional firmware ingredients that are required to boot on |APL|.

.. note:: ``StitchLoader.py`` currenlty only supports stitching with boot guard feature **disabled**.

2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE> -s Outputs/apl/Stitch_Components.zip -o <SBL_IFWI_IMAGE>

  For example, stitching |SPN| IFWI image ``sbl_lfh_ifwi.bin`` from |APL| firmware images downloaded::

    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -i LEAFHILD.X64.0070.R01.1805070352.bin -s Outputs/apl/Stitch_Components.zip -o sbl_lfh_ifwi.bin


See :ref:`stitch-tool` on how to stitching the flashing IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_lfh_ifwi.bin`` to the target board using DediProg SF100 or SF600 programmer.



Booting Yocto Linux
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

1. Download |APL| `Yocto image <https://www.yoctoproject.org/software-overview/layers/bsps/jethro203-leaf-hill/>`_.

2. Create bootable USB key

3. Copy ``initrd.lz`` and ``vmlinuz.efi`` to root directory on USB

   Rename ``initrd.lz`` to ``initrd``; Rename ``vmlinuz.efi`` to ``vmlinuz``

4. Create ``config.cfg`` in root directory with the following content::

  file=/cdrom/preseed/ubuntu.seed boot=casper quiet splash nomodeset

3. Boot from USB key.

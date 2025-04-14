.. _rplp-rki-board:

|RPLP-RKI| Board
----------------

The |RPLP-RKI| Reference Design is a platform developed by Intel, featuring the 13th Gen Intel |reg| Core |trade| Mobile Processor, specifically tailored for network and edge applications.


Prerequisites
^^^^^^^^^^^^^

To start developing |SPN|, the following equipment, software and environments are required:

* |Rock Island Reference Design Board|
* DediProg SF600 Programmer and 1.27mm 2x4 Cable with Female Header
* USB to UART TTL Cable 4 Pins
* Windows host or Linux host (see :ref:`running-on-windows` or :ref:`running-on-linux` for details)
* Internet access

.. |Rock Island Reference Design Board| raw:: html

   <a href="https://www.seavo.com/en/products/products-info_itemid_482.html" target="_blank">Rock Island Reference Design Board</a>


Board Setup
^^^^^^^^^^^

.. image:: /images/rki-setup.jpg
   :width: 600
   :alt: Rock Island Board Setup
   :align: center


Before You Start
^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the pre-installed BIOS image first.

Boot the board and enter BIOS setup menu to get familiar with the board features and settings.


Debug UART
^^^^^^^^^^

Early boot serial debug console can be reached via UART0 located on J9M1 header. Make sure you can observe serial output message running the factory BIOS first.

.. note:: To make your own UART debug adapter by direct wiring, refer to J9M1 header pinout for UART0:

  +--------+--------------+
  |  Pin   |    Signal    |
  +--------+--------------+
  |   1    |  UART0_TXD   |
  +--------+--------------+
  |   2    |  UART0_RXD   |
  +--------+--------------+
  |   5    |     GND      |
  +--------+--------------+

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.


Building
^^^^^^^^

|Rock Island Reference Design Board| is based on Intel |RPLP|. To build::

    python BuildLoader.py build rplp

The output image is generated under ``Outputs\rplp`` directory.


Stitching
^^^^^^^^^

Option 1: Stitch |SPN| image with factory BIOS IFWI image using ``StitchLoader.py``::

    python Platform\RaptorlakeBoardPkg\Script\StitchLoader.py -i <BIOS_IFWI_IMAGE> -s Outputs\rplp\SlimBootloader.bin -o <SBL_IFWI_IMAGE> -p 0xAA00001F

    <BIOS_IFWI_IMAGE> : Input file. Factory BIOS extracted from Rock Island board.
    <SBL_IFWI_IMAGE>  : Output file. New IFWI image with SBL in BIOS region.
    -p <value>        : 4-byte platform data for platform ID (e.g. 1F) and debug UART port index (e.g. 00).

Refer to :ref:`stitch-tool` for more details.

.. note:: StitchLoader.py script works only if Boot Guard in the base image is not enabled, and the silicon is not fused with Boot Guard enabled.
          If Boot Guard is enabled, please use StitchIfwi.py script instead.

Option 2: Stitch |SPN| image with firmware ingredients using ``StitchIfwi.py``:

.. note:: Ensure all the stitch components are ready in the stitching folder.

::

    python Platform\RaptorlakeBoardPkg\Script\StitchIfwi.py -b fvme -s Outputs\rplp\Stitch_Components.zip -c Platform\RaptorlakeBoardPkg\Script\StitchIfwiConfig_rplp.py -w stitching -p rplp -o rki -d 0xAA00001F

The output image is generated under current working directory.


Flashing
^^^^^^^^

Flash the generated SBL_IFWI_IMAGE to |RPLP-RKI| board using a SPI programmer. Header J7Y2 on the board should be used.

.. note::

    Please ensure:

    #. The alignment/polarity when connecting Dediprog to the board.
    #. The power to the board is turned **off** while the programmer is connected (even when not in use).
    #. The programmer is set to update the flash from offset 0x0.


SlimBootloader Binary for Capsule Image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``SlimBootloader.bin`` image generated from the build steps above can be used to create a capsule image for firmware update::

    python BootloaderCorePkg\Tools\GenCapsuleFirmware.py -p BIOS Outputs\rplp\SlimBootloader.bin -k <priv_key> -o FwuImage.bin

Refer to :ref:`generate-capsule` for more details.

.. note:: Boot Guard would not work if directly using ``Outputs\rplp\SlimBootloader.bin`` for capsule image.


Triggering Firmware Update
^^^^^^^^^^^^^^^^^^^^^^^^^^

Refer to :ref:`firmware-update` on how to trigger firmware update flow.

Below is an example to trigger firmware update in |SPN| shell:

#. Copy ``FwuImage.bin`` into root directory on FAT partition of a USB drive
#. Boot and press any key to enter |SPN| shell
#. Type command ``fwupdate`` from shell

Observe |SPN| resets the platform and performs update flow. It resets *multiple* times to complete the update process.

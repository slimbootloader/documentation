.. _ExerciseCorruptSblComponent:

Exercise \\- \ Corrupt |SPN| Component
--------------------------------------

CorruptComponentUtility (static corruption tool)
************************************************

``CorruptComponentUtility.py`` corrupts an SBL component (e.g. an item from its flash map) in either
an IFWI or standalone SBL image. This tool is useful for testing the firmware resiliency and recovery feature
(see :ref:`firmware-resiliency-and-recovery`).

Command Syntax::

    usage: CorruptComponentUtility.py [-h] -i INPUT_IMAGE -o OUTPUT_IMAGE -p COMPONENT_PATH

    optional arguments:
    -h, --help            show this help message and exit
    -i INPUT_IMAGE, --input-image INPUT_IMAGE
                            Specify input IFWI/SBL image file path
    -o OUTPUT_IMAGE, --output-image OUTPUT_IMAGE
                            Specify output IFWI/SBL image file path
    -p COMPONENT_PATH, --path COMPONENT_PATH
                            Specify path of component to corrupt in IFWI/SBL binary (e.g. IFWI/BIOS/TS0/SG1A for BP0 Stage 1A of IFWI binary, use IfwiUtility.py to see all available paths)

Command Example::

    python CorruptComponentUtility.py -i sbl_ifwi.bin -o sbl_ifwi_corrupt.bin -p IFWI/BIOS/TS0/SG1B

If the input/output is an IFWI, the output can be flashed directly to the board to exercise SBL with the corruptions.

If the input/output is an SBL image, the output can be integrated into a FW update capsule and a FW update can be run on the board consuming it (see :ref:`firmware-update`).
This will exercise SBL with the corruptions.

corruptcomp (runtime corruption tool)
*************************************

``corruptcomp`` corrupts an SBL component (e.g. an item from its flash map) in the SPI flash.
This tool is useful for testing the firmware resiliency and recovery feature
(see :ref:`firmware-resiliency-and-recovery`).

This tool is part of the OS loader shell (not the UEFI shell). To get it to show up, set PcdCmdCorruptShellAppEnabled
to TRUE in BootloaderCommonPkg.dec and then build and stich SBL.

Command Syntax::

    Usage: corruptcomp <boot partition> <component>
    Example: corruptcomp 1 SG1A
    Example: corruptcomp 0 SG1B
    Example: corruptcomp 0 SG02

After one or more corruptions, a reset should be run to exercise SBL with the corruptions.

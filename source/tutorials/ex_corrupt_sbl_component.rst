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

If the input/output is an IFWI, the output can be flashed directly to the board and booted to exercise SBL
with the corruptions.

If the input/output is an SBL image, the output can be integrated into a FW update capsule and a FW update can be run on
the board to consume the FW update capsule (see :ref:`firmware-update`). This will exercise SBL with the corruptions.

corruptcomp (runtime corruption tool)
*************************************

``corruptcomp`` corrupts an SBL component (e.g. an item from its flash map) in the SPI flash.
This tool is useful for testing the firmware resiliency and recovery feature
(see :ref:`firmware-resiliency-and-recovery`).

This tool is part of the OS loader shell (not the UEFI shell). To get it to show up, set PcdCmdCorruptShellAppEnabled
to TRUE in BootloaderCommonPkg.dec and then build and stich SBL.

This tool should *not* be enabled in production builds as its use can prevent the system from booting in certain
circumstances.

Command Syntax::

    Usage: corruptcomp <boot partition> <component>
    Example: corruptcomp 1 SG1A
    Example: corruptcomp 0 SG1B
    Example: corruptcomp 0 SG02

Command Example::

    corruptcomp 0 SG1B

After one or more corruptions, a reset should be run to exercise SBL with the corruptions.

Behavior when SBL component is corrupted
****************************************

If SBL resiliency is enabled and an SBL component is corrupted, the system halts for some
time after hash verification of the corrupted component fails. If an IBB corruption is present (i.e. a
corruption in uCode, ACM, Stage 1A, Configuration Data, Key Hash, or Stage 1B), a recovery flow
on the opposite partition is immediately launched. If an OBB corruption is present (i.e. a corruption
in Stage 2 or Firmware Update Payload), the boot is tried a total of 3 times on the current partition
before a recovery flow is launched on the opposite partition. If both partitions are corrupted, the
system halts and reboots are discontinued.

During the recovery flow, the working boot partition is written to the failing boot partition.
In the case of a failure on normal boot, the backup partition is copied to the primary partition. In
the case of a failure on update boot, the primary partition is copied to the backup partition. After
both cases, a normal boot occurs from the primary partition.

The following example shows the logs for when Stage 2 fails during a normal boot and resiliency is enabled::

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 1
    ...
    Loading Stage2 error - Security Violation !
    Failed to load Stage2!
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 1
    ...
    Loading Stage2 error - Security Violation !
    Failed to load Stage2!
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 1
    ...
    Loading Stage2 error - Security Violation !
    Failed to load Stage2!
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 1
    ...
    Boot failure occurred! Failed boot count: 3
    Boot failure threshold reached! Switching to partition: 1
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP1
    MODE: 18
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Firmware update mode, unlock Bios setting
    ...
    Loading Payload ID FWUP
    Loading Component FLMP:FWUP
    ...
    Triggered FW recovery!
    Updating 0x00A00000, Size:0x010000
    ................
    Finished     1%
    ...
    Finished   100%
    Exiting Firmware Update (Status: Success)
    Set next FWU state: 0x77
    Reset required to proceed.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 1
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    ====================Os Loader====================
    ...
    Starting Kernel ...
    ...

The following example shows when Stage 1A fails during an update boot and resiliency is enabled::

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 18
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Firmware update mode, unlock Bios setting
    ...
    Loading Payload ID FWUP
    Loading Component FLMP:FWUP
    ...
    Triggered FW update!
    ...
    =================Read Capsule Image==============
    ...
    Updating Slim Bootloader from version 1 to version 2
    ...
    Updating 0x00600000, Size:0x010000
    ................
    Finished     0%
    ...
    Finished   100%
    Set next FWU state: 0x7E
    Reset required to proceed.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    Partition to be updated is same as current boot partition (primary)
    ...
    BOOT: BP0
    MODE: 18
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Firmware update mode, unlock Bios setting
    ...
    Loading Payload ID FWUP
    Loading Component FLMP:FWUP
    ...
    Triggered FW recovery!
    Updating 0x00600000, Size:0x010000
    ................
    Finished     1%
    ...
    Finished   100%
    Exiting Firmware Update (Status: Success)
    Set next FWU state: 0x77
    Reset required to proceed.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 1
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    ====================Os Loader====================
    ...
    Starting Kernel ...
    ...

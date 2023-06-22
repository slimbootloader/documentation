.. _ExerciseCorruptSblComponent:

Exercise \\- \ Corrupt |SPN| Component
--------------------------------------

.. _CorruptComponentUtility:

CorruptComponentUtility (static corruption tool)
************************************************

The ``CorruptComponentUtility`` tool corrupts an SBL component (e.g. an item from its flash map) in either
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

If the input/output is an IFWI, the output can be flashed directly to the board and booted. This will exercise SBL corruption
handling (e.g. recovery or halt).

If the input/output is an SBL image, the output can be integrated into a FW update capsule and a FW update can be run on
the board to consume the FW update capsule (see :ref:`firmware-update`). This will exercise SBL corruption handing (e.g. recovery or halt).

.. _corruptcomp:

corruptcomp (runtime corruption tool)
*************************************

The ``corruptcomp`` tool corrupts an SBL component (e.g. an item from its flash map) in the SPI flash.
This tool is useful for testing the firmware resiliency and recovery feature (see :ref:`firmware-resiliency-and-recovery`).

The ``corruptcomp`` tool can be added into OSL shell. To get it to show up, include ``ShellCommandRegister (Shell, &ShellCommandCorruptComp);`` 
in the ``LoadShellCommands`` function of ShellCmds.c. Also, to ensure BIOS region is writable by the tool, set 
``FspsConfig->PchWriteProtectionEnable[PrIndex] = FALSE;`` for each existing ``PrIndex`` in the ``UpdateFspConfig`` function of the platform's 
FspsUpdUpdateLib.c.

For example, in C:\\SblPlatform\\SblOpen\\BootloaderCommonPkg\\Library\\ShellLib\\ShellCmds.c, the following addition
should be made:

    .. code-block:: C
        :emphasize-lines: 32

        // Basic Shell commands
        ShellCommandRegister (Shell, &ShellCommandExit);
        ShellCommandRegister (Shell, &ShellCommandHelp);
        ShellCommandRegister (Shell, &ShellCommandMm);
        ShellCommandRegister (Shell, &ShellCommandCpuid);
        ShellCommandRegister (Shell, &ShellCommandMsr);
        ShellCommandRegister (Shell, &ShellCommandMtrr);
        ShellCommandRegister (Shell, &ShellCommandUcode);
        ShellCommandRegister (Shell, &ShellCommandCls);

        if (!FeaturePcdGet (PcdMiniShellEnabled)) {
            // More Shell commands
            ShellCommandRegister (Shell, &ShellCommandPci);
            ShellCommandRegister (Shell, &ShellCommandHob);
            ShellCommandRegister (Shell, &ShellCommandMmap);
            ShellCommandRegister (Shell, &ShellCommandPerf);
            ShellCommandRegister (Shell, &ShellCommandBoot);
            ShellCommandRegister (Shell, &ShellCommandMmcDll);
            ShellCommandRegister (Shell, &ShellCommandCdata);
            ShellCommandRegister (Shell, &ShellCommandDmesg);
            ShellCommandRegister (Shell, &ShellCommandReset);
            ShellCommandRegister (Shell, &ShellCommandFs);
            ShellCommandRegister (Shell, &ShellCommandUsbDev);

            // Load Platform specific shell commands
            ShellExtensionCmds = GetShellExtensionCmds ();
            for (Iter = ShellExtensionCmds; *Iter != NULL; Iter++) {
            ShellCommandRegister (Shell, *Iter);
            }
        }

        ShellCommandRegister (Shell, &ShellCommandCorruptComp); // Added

And in SblOpen\\Platform\\AlderlakeBoardPkg\\Library\\FspsUpdUpdateLib\\FspsUpdUpdateLib.c, the following
changes should be made:

    .. code-block:: C
        :emphasize-lines: 14,20,29

        if (GetBootMode () != BOOT_ON_FLASH_UPDATE) {
            BiosProtected = FALSE;
            PrIndex = 0;
            Status = SpiGetRegionAddress (FlashRegionBios, &BaseAddress, &TotalSize);
            if (!EFI_ERROR (Status)) {
                BiosProtected = TRUE;
                Status = GetComponentInfo (FLASH_MAP_SIG_UEFIVARIABLE, &Address, &VarSize);
                if (!EFI_ERROR (Status)) {
                    //
                    // Protect the BIOS region except for the UEFI variable region
                    //
                    Address -= ((UINT32)(~TotalSize) + 1);

                    FspsConfig->PchWriteProtectionEnable[PrIndex] = FALSE; // Changed from TRUE
                    FspsConfig->PchReadProtectionEnable[PrIndex]  = FALSE;
                    FspsConfig->PchProtectedRangeBase[PrIndex]    = (UINT16) (BaseAddress >> 12);
                    FspsConfig->PchProtectedRangeLimit[PrIndex]   = (UINT16) ((BaseAddress + Address - 1) >> 12);
                    PrIndex++;

                    FspsConfig->PchWriteProtectionEnable[PrIndex] = FALSE; // Changed from TRUE
                    FspsConfig->PchReadProtectionEnable[PrIndex]  = FALSE;
                    FspsConfig->PchProtectedRangeBase[PrIndex]    = (UINT16) ((BaseAddress + Address + VarSize) >> 12);
                    FspsConfig->PchProtectedRangeLimit[PrIndex]   = (UINT16) ((BaseAddress + TotalSize - 1) >> 12);
                    PrIndex++;
                } else {
                    //
                    // Protect the whole BIOS region
                    //
                    FspsConfig->PchWriteProtectionEnable[PrIndex] = FALSE; // Changed from TRUE
                    FspsConfig->PchReadProtectionEnable[PrIndex]  = FALSE;
                    FspsConfig->PchProtectedRangeBase[PrIndex]    = (UINT16) (BaseAddress >> 12);
                    FspsConfig->PchProtectedRangeLimit[PrIndex]   = (UINT16) ((BaseAddress + TotalSize - 1) >> 12);
                    PrIndex++;
                }
            }
            DEBUG (((BiosProtected) ? DEBUG_INFO : DEBUG_WARN, "BIOS SPI region will %a protected\n", (BiosProtected) ? "be" : "NOT BE"));
        }

.. Note:: This tool should *not* be enabled in production builds as its use can prevent the system from booting in certain circumstances.
.. Note:: If SBL is corrupted by this tool and unable to boot, reflashing SBL to SPI is necessary. 

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

OBB Corruption Example
**********************

To test recovery from OBB corruption, first build an IFWI with resiliency (see :ref:`firmware-resiliency-and-recovery`)
and ``corruptcomp`` tool (see :ref:`corruptcomp`) enabled. Then, flash the IFWI to board.

Next, boot to OSL shell and run the following commands:

.. code-block:: bash

  corruptcomp 0 SG02
  reset

The following logs should be output::

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

IBB Corruption Example
**********************

To test recovery from IBB corruption, first build an IFWI with resiliency enabled 
(see :ref:`firmware-resiliency-and-recovery`). Then, flash the IFWI to board.

Next, corrupt the SBL image using the following command:

.. code-block:: bash

    python CorruptComponentUtility.py -i sbl.bin -o sbl_corrupt.bin -p IFWI/BIOS/TS1/SG1B

Next, embed the corrupted SBL image into a FW update capsule and transfer it to 
board. Then, boot to OSL shell and launch a firmware update (see :ref:`firmware-update`).

The following logs should be output::

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

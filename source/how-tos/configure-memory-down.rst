.. _config-memory-down:

Configure Memory Down
----------------------

The term of **Memory Down** is used to describe when memory components such as DRAM devices are physically soldered onto a Printed Circuit Board (PCB). This is an alternative to using mechanical connectors to attach memory modules (DIMM) onto a system. Memory down configuration is often found in the embedded platforms due to the variety of constraints and usage models.

|SPN| supports memory down configuration via FSP UPDs. This guide provides some basic steps to configure |SPN| before calling FSP-M to initialize system memory.

Step 1 - Read schematic and understand DDR memory layout and model from datasheet.

Step 2 - Configure the following memory parameters in |SPN|

Start with ``<platform>\CfgData\CfgData_Memory.yaml`` to understand the possible values for memory parameters

For |UP2|, open ``CfgData_Ext_Up2.dlt`` and customize values that match the actual memory parameters. Given an example for 8GB LPDDR4 memory::

  ...

  PLATFORMID_CFG_DATA.PlatformId           | 0x000E <-- Match actual Board ID

  MEMORY_CFG_DATA.DualRankSupportEnable    | 0x1
  MEMORY_CFG_DATA.RmtMode                  | 0x0
  MEMORY_CFG_DATA.MemorySizeLimit          | 0x0
  MEMORY_CFG_DATA.Ch0_RankEnable           | 0x3  <-- bit masks for dual Rank. 0x1 for single rank; 0x0 for no rank (no memory chip)
  MEMORY_CFG_DATA.Ch0_DramDensity          | 0x2  <-- 8Gb (check datasheet)
  MEMORY_CFG_DATA.Ch1_RankEnable           | 0x3
  MEMORY_CFG_DATA.Ch1_DramDensity          | 0x2
  MEMORY_CFG_DATA.Ch2_RankEnable           | 0x3
  MEMORY_CFG_DATA.Ch2_DramDensity          | 0x2
  MEMORY_CFG_DATA.Ch3_RankEnable           | 0x3
  MEMORY_CFG_DATA.Ch3_DramDensity          | 0x2
  MEMORY_CFG_DATA.RmtCheckRun              | 0x3
  ...

Optionally, you can use |CFGTOOL| to graphically view and modify configurations. See https://slimbootloader.github.io/developer-guides/configuration.html for details.

.. note:: If FSP UPD implementation supports hardcoded SPD table, simply replacing the SPD binary file under ``<platform>\CfgData``. The file name of a SPD binary can be found in ``<platform>\CfgData\CfgData_MemSpd.yaml``. If a platform supports more than one type of memory configuration, the ``MEMORY_CFG_DATA.SpdDataSel`` must be carefully set. Take Tiger Lake as an example: Spd_Ddrlp4.bin and Spd_Ddrlp5.bin are for LPDDR4 and LPDDR5 respectivly. The index of Spd_Ddrlp4.bin is 1, and it is 2 for Spd_Ddrlp5.bin. In a board dlt file::

  MEMORY_CFG_DATA.SpdAddressTable  | {..., 0, ... } <-- when 0, FSP will use hardcoded SPD for the memory slot (mem controller X, channel Y, Dimm Z). Otherwise, FSP reads its SPD from the smbus address.

  MEMORY_CFG_DATA.SpdDataSelXYZ    | 1  <-- using LPDDR4 hardcoded SPD for memory slot XYZ. Or

  MEMORY_CFG_DATA.SpdDataSelXYZ    | 2  <-- using LPDDR5

Step 3 - Build, stitch and test

If the memory configuration is correct, |SPN| should boot all the way to the shell. Verify the memory map information from the log to ensure the memory size matches with hardware.

Otherwise, |SPN| may hang after calling FSP-M and never returns. In this case, you have two troubleshooting options:

1. Re-examine the configuration values, make changes and repeat.
2. Object FSP debug build and get debugging output message during memory training flow.

.. note:: Please contact Intel representatives for how to obtain FSP source code.

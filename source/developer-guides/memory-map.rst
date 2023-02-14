Memory Map
------------

Temporary Memory Layout
^^^^^^^^^^^^^^^^^^^^^^^

|SPN| Stage 1 temporary memory layout::

          Temporary Memory
  +------------------------------+  Top of Low MEM
  |     Memory Mapped Flash      |
  +------------------------------+  Memory-Mapped Flash Base
  |     FSP-T Reserved Data      |
  +------------------------------+  Top of Usable Temporary Memory
  |         Available*           |
  +------------------------------+  End of Stage 1 Data
  |        Stage 1 Data          |
  +------------------------------+  Stage 1 Stack Top/Stage 1 Data Base
  |        Stage 1 Stack         |
  +------------------------------+  Usable CAR Base/Stage 1 Stack Base

.. [*] FSP-M Stack Region is typically chosen from Available Temporary Memory.

Permanent Memory Map
^^^^^^^^^^^^^^^^^^^^

|SPN| internal memory map layout (``BootloaderCoreLib.h``)::

          Reserved MEM
  +------------------------------+  Top of Low MEM
  |       SOC Reserved MEM       |
  +------------------------------+  Top of usable MEM Base
  |       FSP Reserved MEM       |
  +------------------------------+  FSP Reserved MEM Base
  |       LDR Reserved MEM       |
  +------------------------------+  LDR Reserved MEM Base
  |         ACPI NVS MEM         |
  +------------------------------+  ACPI NVS MEM Base
  |       ACPI Reclaim MEM       |
  +------------------------------+  ACPI Reclaim MEM Base
  |       PLD Reserved MEM       |
  +------------------------------+  PLD Reserved MEM Base

        Loader Reserved MEM
  +------------------------------+  StackTop
  |       LDR Stack (Down)       |
  |                              |
  |         LDR HOB (Up)         |
  +------------------------------+  MemPoolEnd (Fixed)
  |                              |
  |   Permanent MEM Pool (Down)  |
  |                              |
  +------------------------------+  MemPoolCurrTop (Moving down)
  |                              |
  +------------------------------+  MemPoolCurrBottom (Moving up)
  |                              |
  |   Temporary MEM Pool (Up)    |
  |                              |
  +------------------------------+  MemPoolStart (Fixed)

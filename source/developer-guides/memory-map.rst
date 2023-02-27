Memory Map
------------

Temporary Memory Layout
^^^^^^^^^^^^^^^^^^^^^^^

|SPN| Stage 1 temporary memory layout::

          Temporary Memory
  +------------------------------+  Top of 4GB
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

Memory Management
^^^^^^^^^^^^^^^^^

* Once main memory has been initialized, Stage 1B migrates the Slim Bootloader stack from temporary memory to the permanent
  memory and also reserves a portion of memory to be used for global data structures (``LdrGlobal``, GDT, IDT), stack, heap,
  and payload.

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
  |    Global Data structures    |      |
  +------------------------------+      |
  |                              |      |
  |   Permanent MEM Pool (Down)  |      |
  |                              |      v
  +------------------------------+  MemPoolCurrTop (Moving down)
  |                              |
  +------------------------------+  MemPoolCurrBottom (Moving up)
  |                              |      ^
  |   Temporary MEM Pool (Up)    |      |
  |                              |      |
  +------------------------------+  MemPoolStart (Fixed)


Memory Allocation within Slim Bootloader
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Slim Bootloader has two different libraries for allocating memory during various
execution phases of the bootloader.

* Stage 1A, Stage 1B, Stage 2 use ``MemoryAllocationLib`` present in ``BootloaderCorePkg``.
* OsLoader and FwUpdate use ``FullMemoryAllocationLib`` present in ``BootloaderCommonPkg``.

``MemoryAllocationLib``
~~~~~~~~~~~~~~~~~~~~~~~

``MemoryAllocationLib`` allocates memory from the Loader Reserved Memory region. This
can be seen diagrammatically in the "Loader Reserved MEM" layout shown above.

``MemoryAllocationLib`` provides services for allocating two different types of memory -

* Bootloader permanent memory:

  * Bootloader permanent memory is used by the bootloader to store device tables, S3 Data,
    SBL container headers, etc.
  * Memory allocated from bootloader permanent memory region cannot be freed
  * Note that permanent memory does not mean that it is persistent across reboots
  * ``AllocatePool()``, ``AllocateZeroPool()``, ``AllocatePages()``, ``AllocateAlignedPages()``
    allocate memory from the Loader Reserved region starting from ``MemPoolEnd`` which grows
    down towards ``MemPoolStart``

    * Currently used allocated memory is between ``MemPoolEnd`` and ``MemPoolCurrTop``
    * Loader Reserved Memory is reported to the OS as "Reserved" memory

* Temporary Memory:

  * Temporary memory requested by a stage is expected to be used by that stage itself
  * Temporary memory is allocated starting from ``MemPoolStart`` and grows up towards
    ``MemPoolEnd``.

    * Currently used temporary memory is between ``MemPoolStart`` and ``MemPoolEnd``

  * Temporary Memory is freed by the ``FreeTemporaryMemory()`` API call.

    * Calling ``FreeTemporaryMemory()`` with ``NULL`` as a parameter will free all allocated
      memory within the temporary memory region.

``FullMemoryAllocationLib``
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Stage 2 passes the HOB list pointer, and the Payload executable base to the payload.
* The HOB list pointer contains the pointer to the HOBs consumed by the payload. The ``MEMORY_MAP_INFO`` HOB will report memory available to the payload.

  * The payload reserved memory region from memory map info hob is identified by the ``MEM_MAP_TYPE_RESERVED`` entry type and the ``MEM_MAP_FLAG_PAYLOAD``
    flag.

* In case of tightly-coupled payloads, once the payload is loaded, ``PayloadInit()`` is called by ``PayloadEntryLib`` to initialize global data for the
  payload.
* ``PayloadInit()`` in turn calls ``AddMemoryResourceRange()`` from ``FullMemoryAllocationLib`` to  initialize the memory ranges from which memory
  will be allocated to the payload. 
* The size of the reserved memory, heap, and stack is determined by their respective PCDs defined in ``BoardConfig.py``.

  * ``PLD_RSVD_MEM_SIZE``, ``PLD_HEAP_SIZE``, and ``PLD_STACK_SIZE``

* Once the memory ranges are initialized, dynamic memory allocation will be done from the payload heap region.

* The memory map of the Payload can be seen below:

.. code-block:: text

                  Payload Memmap
  +--------------------------------------------+ TOLUM
  |   Reserved memory for Slimboot core        |
  +--------------------------------------------+ RsvdBase + RsvdSize
  |   Reserved memory for Payload              |
  +--------------------------------------------+ RsvdBase
  |   + DMA buffer                             |
  +--------------------------------------------+ DmaBase
  |   + Payload heap                           |
  +--------------------------------------------+ HeapBase
  |   + Payload stack                          |
  +--------------------------------------------+ StackBase
  |   Free memory                              |
  +--------------------------------------------+ 0

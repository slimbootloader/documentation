Flash Map
-----------

Flash map is a manifest to describe the binary layout in |SPN| image. With flash map, |SPN| is able to locate each subcomponent. It also makes it possible for post build script to examine or patch individual component, e.g. configuration data or payload, without having to recompile |SPN| source.

The flash map data structure is an array based manifest with some header information:

.. code-block:: c

  typedef struct {
    UINT32    Signature;
    UINT32    Flags;
    UINT32    Offset;
    UINT32    Size;
  } FLASH_MAP_ENTRY_DESC;

  typedef struct {
    UINT32                Signature;
    UINT16                Version;
    UINT16                Length;
    UINT8                 Attributes;
    UINT8                 Reserved[3];
    UINT32                RomSize;
    FLASH_MAP_ENTRY_DESC  EntryDesc[];
  } FLASH_MAP;

|SPN| embeds the flash map structure at an offset in the |SPN| image so that the flash map is accessible at the following memory address during boot::

  #define FLASH_MAP_ADDRESS       0xFFFFFFF8


.. Note:: On Intel |APL|, flash map content is determined at the end of the build process as the size of some subcomponents are not known in advance.

Flash Components
^^^^^^^^^^^^^^^^^
========= =========================
Signature  Component Description
========= =========================
SG1A       Stage 1A
SG1B       Stage 1B
SG02       Stage 2
ACM0       ACM module
UCOD       Microcode Patch
MRCD       MRC training data
VARS       Variable data
KEYH       Key hash store
PYLD       Normal Payload (typically OS loader)
EPLD       Extended Payload container (UEFI payload, Linux payload, etc)
IAS1       First IAS image (typically for provisioning or recovery use)
IAS2       Second IAS image
FWUP       Firmware Update Payload
CNFG       External configuration data
_BPM       Boot Policy Manifest
OEMK       OEM Key Manifest
RSVD       Reserved
EMTY       Empty
UNKN       Unknown
========= =========================


Flash Layout
^^^^^^^^^^^^^^^^^

|SPN| contains all critical boot components with redundant copy on boot flash so that if one of them is corrupted due to hardware defect or during firmware update process, |SPN| is able to recover from the 2nd copy to boot, thus avoiding bricking the board in total failure.

.. note:: On |APL|, flash map is determined in the stitching process instead of build process.


An flash layout from QEMU build is shown below::

  Flash Map Information:
        +------------------------------------------------------------------------+
        |                              FLASH  MAP                                |
        |                         (RomSize = 0x00200000)                         |
        +------------------------------------------------------------------------+
        |   NAME   |     OFFSET  (BASE)     |    SIZE    |         FLAGS         |
        +----------+------------------------+------------+-----------------------+
        +------------------------------------------------------------------------+
        |                               TOP SWAP A                               |
        +------------------------------------------------------------------------+
        |   SG1A   |  0x1f8000(0xFFFF8000)  |  0x008000  |  Uncompressed, TS_A   |
        |   EMTY   |  0x1f0000(0xFFFF0000)  |  0x008000  |  Uncompressed, TS_A   |
        +------------------------------------------------------------------------+
        |                               TOP SWAP B                               |
        +------------------------------------------------------------------------+
        |   SG1A   |  0x1e8000(0xFFFE8000)  |  0x008000  |  Uncompressed, TS_B   |
        |   EMTY   |  0x1e0000(0xFFFE0000)  |  0x008000  |  Uncompressed, TS_B   |
        +------------------------------------------------------------------------+
        |                              REDUNDANT A                               |
        +------------------------------------------------------------------------+
        |   CNFG   |  0x1df000(0xFFFDF000)  |  0x001000  |  Uncompressed, R_A    |
        |   FWUP   |  0x1bf000(0xFFFBF000)  |  0x020000  |  Compressed  , R_A    |
        |   SG1B   |  0x1a0000(0xFFFA0000)  |  0x01f000  |  Compressed  , R_A    |
        |   SG02   |  0x180000(0xFFF80000)  |  0x020000  |  Compressed  , R_A    |
        +------------------------------------------------------------------------+
        |                              REDUNDANT B                               |
        +------------------------------------------------------------------------+
        |   CNFG   |  0x17f000(0xFFF7F000)  |  0x001000  |  Uncompressed, R_B    |
        |   FWUP   |  0x15f000(0xFFF5F000)  |  0x020000  |  Compressed  , R_B    |
        |   SG1B   |  0x140000(0xFFF40000)  |  0x01f000  |  Compressed  , R_B    |
        |   SG02   |  0x120000(0xFFF20000)  |  0x020000  |  Compressed  , R_B    |
        +------------------------------------------------------------------------+
        |                             NON REDUNDANT                              |
        +------------------------------------------------------------------------+
        |   PYLD   |  0x020000(0xFFE20000)  |  0x100000  |  Compressed  ,  NR    |
        |   VARS   |  0x01e000(0xFFE1E000)  |  0x002000  |  Uncompressed,  NR    |
        |   EMTY   |  0x001000(0xFFE01000)  |  0x01d000  |  Uncompressed,  NR    |
        +------------------------------------------------------------------------+
        |                              NON VOLATILE                              |
        +------------------------------------------------------------------------+
        |   RSVD   |  0x000000(0xFFE00000)  |  0x001000  |  Uncompressed,  NV    |
        +----------+------------------------+------------+-----------------------+

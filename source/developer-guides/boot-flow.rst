.. _build-process:

Build Process
--------------

|SPN| build process is implemented in top level build script ``BuildLoader.py``. The following diagram illustrates main steps:

.. graphviz:: /images/build_steps.dot

The generated files are located in ``Build/`` directory.

The |SPN| image, configuration data, and (generated) helper scripts, are located in ``Outputs/`` directory.

.. Note:: To assist debugging, the build process also generates ``SlimBootloader.txt`` file which contains flash layout details for each component in |SPN| image.


.. _boot-flow:

Boot Flow
-------------

|SPN| uses a linear staged boot flow to initialize platform and launch OS. It consists of four stages:

========= ================
Stage      Description
========= ================
Stage 1A   Pre-memory initialization
Stage 1B   Initialize main memory
Stage 2    Post memory initialization: initialize CPU, I/O controllers, devices etc.
Payload    Load, verify and launch OS images; or perform firmware update
========= ================

.. graphviz:: /images/boot_flow.dot

.. Note:: When verified boot is enabled, each current stage verifies the next stage before transferring control to the next. If verification fails, |SPN| halts the system boot.


.. _call-graph:

End-to-End Call Graph
-----------------------

The function call graph in |SPN| code from reset vector to OS launch.

.. image:: /images/call_graph.png
   :width: 600
   :alt: |SPN| Calling Graph
   :align: center



Platform Initialization
-------------------------

In |SPN|, board initialization code is located in ``Platform/<platform_foo>`` directory. Each stage provides a 'hook point' for board specific code. To port a new board, one should implement changes in ``BoardInit()`` function for each stage under ``Platform/<platform_foo>/Library`` directory::

    VOID
    BoardInit (
      IN  BOARD_INIT_PHASE  InitPhase
      );


During board initialization, |SPN| further divides the flow into multiple phases to provide a fine granularity control. These phases are defined in ``PlatformService.h``::

    typedef enum {
      PreTempRamInit     = 0x10,
      PostTempRamInit    = 0x20,
      PreConfigInit      = 0x30,
      PostConfigInit     = 0x40,
      PreMemoryInit      = 0x50,
      PostMemoryInit     = 0x60,
      PreTempRamExit     = 0x70,
      PostTempRamExit    = 0x80,
      PreSiliconInit     = 0x90,
      PostSiliconInit    = 0xA0,
      PrePciEnumeration  = 0xB0,
      PostPciEnumeration = 0xC0,
      PrePayloadLoading  = 0xD0,
      PostPayloadLoading = 0xE0,
      EndOfStages        = 0xF0,
      ReadyToBoot        = 0xF8,
      EndOfFirmware      = 0xFF
    } BOARD_INIT_PHASE;

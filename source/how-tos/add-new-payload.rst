.. _create-new-payload:

Create New Payload
---------------------------

.. note:: Before you decide to support a new payload in |SPN|, it is recommended to check whether the existing payloads can be updated to support the new requirement.


For **tightly-coupled** payload, two steps are required to integrate a new payload:

#. Create a new payload starts with adding a new module in ``PayloadPkg/<payload_bar>`` with entry point function ``PayloadMain()``.

   See :ref:`package-dependency` when you are implementing payload code.


#. Build and integrate the new payload

    The image size and memory location of the new payload can be configured in ``BoardConfig.py``. The following values are used in |APL| payload configurations::

        PAYLOAD_SIZE         = 0x0001F000
        EPAYLOAD_SIZE        = 0x00120000
        LOADER_RSVD_MEM_SIZE = 0x00B8C000
        PLD_RSVD_MEM_SIZE    = 0x00500000
        PAYLOAD_LOAD_HIGH    = 1


For **loosely-coupled** payload, you are full control of payload design and implementation.

For example, UEFI Payload is loosely-coupled payload.


HelloWorld Payload
---------------------------

|SPN| provides a HelloWorld payload example to illustrate how to write a very simple payload.


To build the HelloWorld payload, run the following command from |SPN| source tree::

  python BuildLoader.py build_dsc PayloadPkg\PayloadPkg.dsc

The generated payload binary will be located at::

  Build\PayloadPkg\DEBUG_VS2019\IA32\HelloWorld.efi

.. note:: The path might change a little bit if using different toolchain or build options.

To use HelloWorld payload as the default payload instead of the OsLoader on QEMU platform, build |SPN| with the following command::

  copy Build\PayloadPkg\DEBUG_VS2019\IA32\HelloWorld.efi PayloadPkg\PayloadBins /y
  python BuildLoader.py build qemu -p HelloWorld.efi:HLWD:Lz4

This generated SlimBootloader.bin will boot into HelloWorld payload on QEMU platform.

To add HelloWorld payload as additional paylaod, build |SPN| with the following command::

  copy Build\PayloadPkg\DEBUG_VS2019\IA32\HelloWorld.efi PayloadPkg\PayloadBins /y
  python BuildLoader.py build qemu -p OsLoader.efi:LLDR:Lz4;HelloWorld.efi:HLWD:Lz4

The generated SlimBootloader.bin will boot into OsLoader or HelloWorld payload on QEMU platform depends
on the GEN_CFG_DATA.PayloadId value at build time and runtime.

.. note:: GEN_CFG_DATA.PayloadId can be customized in board CFGDATA DLT file. The PayloadId can be
  updated by |SPN| at runtime code by SetPayloadId() function.

Please refer to :ref:`integrate-multiple-payloads` for multiple payloads support.




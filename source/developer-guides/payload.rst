.. _payload:

Payloads
------------------

|SPN| payload stage is to boot a target OS. It is a modular design to extend bootloader to perform a purpose-driven functionality that is generally independent of platform hardware.

Payloads
^^^^^^^^^^^^^^^^^^^

Os Loader (Built-in)
  A versatile linux loader implementation that boots Linux, hypervsior, Android, and ELF or PE executables. It also supports launching OSes compliant with the MultiBoot specification.

  When built as an FV formatted payload OS Loader permits the inclusion and launching of a pre-OS payload binary that will hand-off control to an OS after the pre-OS payload finishes execution.

  See :ref:`enable-pre-os-payload` for more details.

Firmware Update Payload (Built-in)
  A special purpose payload to update full boot flash in a secure and fault-tolerant flow.

UEFI Payload (External)
  A EDK II based payload implementation to boot Windows. It provides secure boot, SMM, and UEFI runtime services.

Custom Payload
  |SPN| supports launching customized payloads that provides purpose-driven functionality.


Payload Types
^^^^^^^^^^^^^^^^

Tightly Coupled
  Implementation depends on |SPN| source code to build. It requires platform specific libraries.

Loosely Coupled
  Implementation can either be self-contained or depends on libraries in ``BootloaderCommonPkg`` and ``PayloadPkg``. The platform abstraction is provided through Hand-off-Blocks (HOB) data structures. These payloads are platform agnostic.


Multiple Payload Support
^^^^^^^^^^^^^^^^^^^^^^^^^^

In some use cases, more than one payload is necessary in |SPN|. However, it is difficult to fit all payloads into limited flash device. For example, UEFI payload image can be over 1MB in size. This feature is designed to support multiple payloads, allowing built-in payload (OsLoader) reside in redundant region, while the **external** payloads in non-redundant region.

See :ref:`integrate-multiple-payloads` for more details.

See :ref:`create-new-payload` for more details.

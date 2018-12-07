.. _faq:

Frequently Asked Questions
---------------------------

What is |PN| (|SPN|)?
    |PN| is an open-source boot firmware, built from the ground up to be small, secure and optimized running on Intel x86 architecture.

What platforms are supported by |SPN|?
    Initially, |SPN| supports the following |APL|: |UP2| board, Intel Leaf Hill CRBs and QEMU virtual machine. More upcoming platforms will be supported in the future.

What license does |SPN| use?
    |SPN| is released under BSD 2-Clause "Simplified" License.

Who are the maintainers of |SPN|?
    Intel maintains open source code on |GitHub|.
  
.. |GitHub| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader" target="_blank">GitHub</a>

What are options to debug |SPN|?
    |SPN| supports source level debugging using UDK debug tool (via UART). Depending on the board configuration, developers can also debug |SPN| with Intel trace hub, secure debug token (if enabled) or memory buffers.

Is Embedded Controller (EC) supported?
    No. Different boards may have differenct EC or SuperIO. Developers need implement the code for the target board.

Does it support RTOS?
    |SPN| features loading x86 ELF executables in its payload stage. We have verified loading Open Source Zephyr RTOS (See :ref:`boot-zephyr`).

What tool chains are supported to compile |SPN|?
    |SPN| supports Microsoft Visual Studio 2015 and GNU GCC toolchains (gcc 5 or newer). Additional tools, include Python (2.7), nasm, and IASL are required to build |SPN|.

    The current version of BaseTools is UDK2018 from EDKII open source project.

Does |SPN| support verified boot and measured boot?
    Yes. |SPN| supports both from software point of view. In order to enable hardware root-of-trust in |SPN|, the Intel stitching software kit is required. For measured boot, |SPN| supports TPM 2.0.

Does |SPN| support SMM?
    |SPN| does not support SMM. If SMM is required, a new |SPN| payload can be created to support it.

Does |SPN| support Over-the-Air (OTA) firmware update?
    |SPN| has a built-in firmware update payload that features power-fail safe mechanism. OS specific OTA support can be implemented based on the provided firmware update interface in |SPN|.

Does |SPN| support splash screen?
    Yes. Custom splash screen can be enabled or disabled (for boot performance) via |SPN| build options.

Does |SPN| support legacy boot?
    |SPN| currently does not support option ROM or CSM mode.

Do you have a porting guide for new boards?
    Please visit and search :ref:`developer-guide` section first. We plan to post step-by-step porting guides with more details.

I need help...
    Subscribe to our |ML| or search |ML_ARCHIVE| first.

.. |ML| raw:: html

   <a href="https://lists.01.org/mailman/listinfo/sbl-devel" target="_blank">Mailing List</a>
   
.. |ML_ARCHIVE| raw:: html

   <a href="https://lists.01.org/pipermail/sbl-devel/" target="_blank">Archives</a>

It doesn't work for me...
    Email us via our mailing list or direclty submit an issue on |ISSUES|.

.. |ISSUES| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader/issues" target="_blank">GitHub</a>  

I want to contribute...
    You are welcome to contribute our project in different ways including code, documentation or ideas. We'd be happy to review your contributions!

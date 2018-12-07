.. _faq:

Slim Bootloader (SBL) Open Source FAQ
-------------------------------------

**1. What is Slim Bootloader (SBL)?**

    Slim Bootloader is an open-source boot firmware, built from the ground up to be small, secure and highly optimized running on Intel x86 architecture.

**2. What platforms are supported by SBL?**

    Initially, SBL supports the following Apollo Lake-based platform: Up Squared board, Intel Leaf Hill CRBs, MinnowBoard 3, and QEMU virtual machine. More upcoming platforms would be supported in the future.

**3. What license does SBL have?**

  SBL is released under BSD 2-Clause "Simplified" License.

**4. Who are the maintainers of SBL?**

  Intel maintains open source code on GitHub: |slimbootloader|.
  
.. |slimbootloader| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader" target="_blank">slimbootloader</a>  

**5. What are options to debug SBL?**

  SBL supports source level debugging with UDK debug tool. It also supports debugging via Intel trace hub, secure debug token (if enabled) and memory buffers. 

**6. Is embedded controller (EC) supported?**

  No. If an EC is required, it needs to be implemented on the target board.

**7. Does it support RTOS?**

  SBL features loading an x86 ELF executable in payload stage. RTOS is typically built as an ELF format and we have verified loading an open source RTOS called Zephyr (refer to :ref:`boot-zephyr`).

**8. What tool chains are supported to compile SBL?**

  SBL supports Microsoft Visual Studio 2015 and GNU GCC toolchains (gcc5 and newer). Additional tools, include Python (2.7), nasm, and IASL are required to build SBL.
  The BaseTools version on GitHub is UDK2018 from EDKII open source project.
  Intel C compiler (ICC) will be supported in the future.

**9. Does SBL support verified boot and measured boot?**

  Yes. SBL supports both from software point of view. However, to enable the hardware root-of-trust in SBL, the stitching software kit from Intel is required.
  For measured boot, TPM 2.0 supported is included.

**10. Does SBL support SMM?**

  No, SBL does not support SMM. If SMM is needed, then a new SBL payload can be created to support it.

**11. Does SBL support Over-the-Air (OTA) firmware update?**

  SBL has a built-in firmware update feature that supports power-fail update mechanism. OS specific OTA support can be implemented based on the existing firmware update interface.

**12. Does SBL support splash screen?**

  Yes. It can be configured via build options to disable it

**13. Does SBL support legacy boot?**

  SBL currently does not support option rom or CSM mode.

**14. Does SBL support Embedded Controller (EC)**

  EC is a board specific feature. SBL currently does not have EC support and can be added in the future.

**15. Do you have a porting guide for SBL?**

  You can visit :ref:`developer-guide` session first. We plan to post more details step-by-step porting guide soon.

**16. I need help...**

  Subscribe to our mailing list |here| or search |The Sbl-devel Archives|.

.. |here| raw:: html

   <a href="https://lists.01.org/mailman/listinfo/sbl-devel" target="_blank">here</a>
   
.. |The Sbl-devel Archives| raw:: html

   <a href="https://lists.01.org/pipermail/sbl-devel/" target="_blank">The Sbl-devel Archives</a>

**17. It doesn't work...**

  Email to our mailing list |here| or submit an issue on |GitHub|.
  
.. |here| raw:: html

   <a href="https://lists.01.org/mailman/listinfo/sbl-devel" target="_blank">here</a>

.. |GitHub| raw:: html

   <a href="https://github.com/slimbootloader/slimbootloader/issues" target="_blank">GitHub</a>  
  

**18. I want to contribute...**

  You are welcome to contribute our project in different ways including code, documentation or ideas. We'd be happy to review your contributions!

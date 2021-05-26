.. _getting-started_qsp:


QSP Simics Platform
-----------------------


Building SBL
^^^^^^^^^^^^

To build |SPN| for Intel QSP simics platform (it is the same image as QEMU, SBL will auto detect the platform at runtime)::

    python BuildLoader.py build qemu

The output images are generated under ``Outputs/qemu/SlimBootloader.bin`` directory.

.. note:: QSP simics platform does not require stitching the |SPN| into an IFWI.



Setting up QSP Simics
^^^^^^^^^^^^^^^^^^^^^

Please head over to this link to setup Intel Simics® Simulator Public Release Preview:

|https://downloadcenter.intel.com/download/30403/Intel-Simics-Public-Release-Preview/|

.. |https://downloadcenter.intel.com/download/30403/Intel-Simics-Public-Release-Preview/| raw:: html

   <a href="https://downloadcenter.intel.com/download/30403/Intel-Simics-Public-Release-Preview/" target="_blank">https://downloadcenter.intel.com/download/30403/Intel-Simics-Public-Release-Preview/</a>


.. note::
  Currently QSP Simics supports Linux environment runtime only

  Please download both tar.gz and ispm file to your Linux host directory


Please refer to the **Installation and Getting Started Guide.pdf** at bottom of the Intel Simics page to install the Intel Simics and get started!



Boot to Shell on QSP Simics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before trying on Slim Bootloader, please make sure that you have gone through all the step in **Installation and Getting Started Guide.pdf** to get yourself familiaze with the Simics!

Once it is done, proceed to load **SlimBootloader.bin** using Simics CLI method (in Simics terminal)::

  simics> run-command-file targets/qsp-x86/firststeps.simics bios_image = "/home/(SlimBootloader.bin path)"

Now test the newly built |SPN| image in QEMU emulator from command line::

  qemu-system-x86_64 -machine q35 -nographic -serial mon:stdio -pflash Outputs/qemu/SlimBootloader.bin

Console outputs::

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    ==================== OS Loader ====================
    Press any key within 1 second(s) to enter the command shell
    Shell>





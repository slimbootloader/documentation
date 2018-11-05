.. _Exercise 2:

Exercise 2 \\- \ Run Bootloader on QEMU
---------------

.. note::
  **In this exercise, we'll learn how to boot to SBL Shell in QEMU emulator.**


You can execute |SPN| with the following steps:

* Working on Command Prompt

* Execute bootloader on QEMU by type-in cmd:

 - Windows::

    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio  -pflash Outputs\qemu\SlimBootloader.bin
 
 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin


.. image:: /images/Ex2.jpg
   :alt: Compile completed
   :align: center


.. tip::
    Quit QEMU emulator    
    
    - Windows::
    
        CTRL + c
    
    - Linux::

        CTRL + a, then x


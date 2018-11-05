.. _Exercise 4:

Exercise 4 \\- \ Boot to Linux
---------------

.. note::
  **In this exercise, we'll learn how to boot to Linux.**


You can execute |SPN| with the following steps:

* Wrking on Command Prompt Shell window


* Rebuild SlimBoot by type-in cmd::

    python BuildLoader.py build qemu

* Completion: you will see ``Done [qemu]`` on the screen after compile completed

* Execute bootloader on QEMU by type-in cmd:

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio -pflash Outputs\qemu\SlimBootloader.bin -drive id=mydisk,if=none,file=..\Misc\QemuImg\QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d

 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin -drive id=mydisk,if=none,file=../Misc/QemuImg/QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d

 


.. image:: /images/Ex4.jpg
   :alt: Compile completed
   :align: center


.. tip::
    * If run QEMU in Windows,  Ctrl+Break to exit.
    
    * The login to Linux, type::
    
        root 
    
    * To shutdown Linux, type::

        halt



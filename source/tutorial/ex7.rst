.. _Exercise 7:

Exercise 7 \\- \ Feature Customization - Boot Order
----------------

.. note::
  **In this exercise, we'll learn how to change boot order.**


You can execute |SPN| with the following steps:

* Check current boot order in QEMU:

  - Look through the boot log on Command Prompt and locate string ``Getting boot image from...`` to determine  the 1st boot device::
  
        python BuildLoader.py build qemu


  .. image:: /images/Ex7-1.jpg
    :alt: Compile completed
    :align: center
  
---------
* Modify board specific library, 

  * in file ``..\SlimBoot\Platform\QemuBoardPkg\Library\Stage2BoardInitLib\Stage2BoardInitLib.c``
  * In function ``UpdateOsBootMediumInfo ()``  
  * Add following at the end of functiona to override the boot order::
      
        OsBootOptionList->CurrentBoot = 2;

  .. image:: /images/Ex7-2.jpg
    :alt: Compile completed
    :align: center

------------  
* Rebuild SlimBoot by type-in cmd::

    python BuildLoader.py build qemu
    
* Completion: you will see ``Done [qemu]`` on the screen after compile completed    

* Execute bootloader on QEMU by type-in cmd:

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio -pflash Outputs\qemu\SlimBootloader.bin -drive id=mydisk,if=none,file=..\Misc\QemuImg\QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d

 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin -drive id=mydisk,if=none,file=../Misc/QemuImg/QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d
 
* Check the console Window to see the difference
 
  .. image:: /images/Ex7-3.jpg
    :alt: Compile completed
    :align: center
    

.. tip::
    * Board customization can be done through board specific libraries, such as ``..\Stage1ABoardInit/Stage1BBoardInit/Stage2BoardInit``
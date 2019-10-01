.. _ExerciseFeatureCustomBootOrder:

Exercise \\- \ Feature Customization - Boot Order
---------------------------------------------------

.. note::
  **In this exercise, we'll learn how to change boot order from source code.**


You can execute |SPN| with the following steps:

1. Check current boot order in QEMU:

  - Look through the boot log on Command Prompt and locate string ``Getting boot image from...`` to determine  the 1st boot device::
  
        python BuildLoader.py build qemu


  .. image:: /images/ex7-1.jpg
    :alt: Compile completed
    :align: center
 

2. Modify board specific library, 

  * in file ``<sbl_tree>\Platform\QemuBoardPkg\Library\Stage2BoardInitLib\Stage2BoardInitLib.c``
  * In function ``UpdateOsBootMediumInfo ()``  
  * Add following at the end of the function to override the boot order::
      
        OsBootOptionList->CurrentBoot = 2;

  .. image:: /images/ex7-2.jpg
    :alt: Compile completed
    :align: center

|
 
3. Rebuild |SPN| by using the following command::

    python BuildLoader.py build qemu
    
4. Completion: you will see ``Done [qemu]`` on the screen after compile completed    

5. Execute |SPN| on QEMU by using the following command:

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio -pflash Outputs\qemu\SlimBootloader.bin -drive id=mydisk,if=none,file=..\Misc\QemuImg\QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d

 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin -drive id=mydisk,if=none,file=../Misc/QemuImg/QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d
 
6. Check the console Window to see the difference
 
  .. image:: /images/ex7-3.jpg
    :alt: Compile completed
    :align: center
    

.. tip::

    Board customization can be done through board specific libraries, such as ``<sbl_tree>\Stage1ABoardInit/Stage1BBoardInit/Stage2BoardInit``

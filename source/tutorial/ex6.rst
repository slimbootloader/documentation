.. _Exercise 6:

Exercise 6 \\- \ Feature Customization - VerifiedBoot
---------------

.. note::
  **In this exercise, we'll learn how to enable and verify VerifiedBoot.**


You can execute |SPN| with the following steps:

* Use HEX editor to modify one byte in the SlimBoot image:

  - Rebuild SlimBoot by type-in cmd::
  
        python BuildLoader.py build qemu


  * Completion: you will see ``Done [qemu]`` on the screen after compile completed
  
  * Check Flash Map on stage2 offset located at where (example here stage2 is located at 0x18000000)
  
  
  .. image:: /images/Ex6-1.jpg
    :alt: Compile completed
    :align: center
  
  

  * Open ``SlimBootloader.bin`` on ``..\SlimBoot\Outputs\qemu\``
  
  * Goto offset ``0x18000000`` and select one byte to modify it to ``0x00``, and save the image

  * Example here updated offset ``0x18000025`` (Make sure to **SAVE** the changes!)

-----------

* Execute bootloader on QEMU by type-in cmd::

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio  -pflash Outputs\qemu\SlimBootloader.bin

 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin


   .. image:: /images/Ex6-2.jpg
     :alt: Compile completed
     :align: center


  * Boot up failed on stage 1B 
  
  * Modify board configuration file, **CHANGE** the line in file ``..\SlimBoot\Platform\QemuBoardPkg\BoardConfig.py`` ::
  
        self.HAVE_VERIFIED_BOOT = 0 
        
        
    .. image:: /images/Ex6-4.jpg
      :alt: Compile completed
      :align: center

-------------  

  * Rebuild SlimBoot by type-in cmd::

        python BuildLoader.py build qemu

  * Completion: you will see ``Done [qemu]`` on the screen after compile completed



  * Use HEX editor to modify one byte in the SlimBootloader image:
  
    - Open ``SlimBootloader.bin`` on ``..\SlimBoot\Outputs\qemu\``
    
    - Goto offset ``0x18000025`` and modify it to ``0x00``, and *SAVE* the image
    
    - Execute bootloader on QEMU by type-in cmd:
 
        - Windows::
 
            "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio  -pflash Outputs\qemu\SlimBootloader.bin

        - Linux::
 
            qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin



   .. image:: /images/Ex6-3.jpg
     :alt: Compile completed
     :align: center



   .. image:: /images/Ex6-5.jpg
     :alt: Compile completed
     :align: center




.. tip::
    * BoardConfig.py contains lots of options for customization.  Most of the SlimBoot static features and Flash image layout can be customized here.


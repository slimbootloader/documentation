.. _ExerciseFeatureCustomVerifiedBoot:

Exercise \\- \ Feature Customization - Verified Boot
------------------------------------------------------

.. note::
  **In this exercise, we'll learn how to enable and verify Verified Boot, it will demonstrate that boot stage signature verification will fail if a user modifies a byte in one of the stages**


You can execute |SPN| with the following steps:

1. Use HEX editor to modify one byte in the |SPN| image:

  1.) Rebuild |SPN| by using the following command::
  
        python BuildLoader.py build qemu


  2.) Completion: you will see ``Done [qemu]`` on the screen after compile completed
  
  3.) Check Flash Map on stage2 offset located at where (example here stage2 is located at 0x18000000)
    
  .. image:: /images/ex6-1.jpg
    :alt: Compile completed
    :align: center

|   

  4.) Open ``SlimBootloader.bin`` on ``<sbl_tree>\Outputs\qemu\``
  
  5.) Goto offset ``0x18000000`` and select one byte to modify it to ``0x00``, and save the image
  
   .. image:: /images/ex6-2.jpg
     :alt: Compile completed
     :align: center

  6.) Example here updated offset ``0x18000025`` (Make sure to **SAVE** the changes!)

|

2. Execute |SPN| on QEMU by using the following command

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio  -pflash Outputs\qemu\SlimBootloader.bin

 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin





3. Boot up failed on stage 1B 


   .. image:: /images/ex6-3.jpg
     :alt: Compile completed
     :align: center

  
4. Modify board configuration file, **CHANGE** the line in file ``<sbl_tree>\Platform\QemuBoardPkg\BoardConfig.py`` ::
  
        self.HAVE_VERIFIED_BOOT = 0 
        
        
   .. image:: /images/ex6-4.jpg
      :alt: Compile completed
      :align: center

-------------  

5. Rebuild |SPN| by using the following command::

        python BuildLoader.py build qemu

6. Completion: you will see ``Done [qemu]`` on the screen after compile completed



7.  Use HEX editor to modify one byte in the SlimBootloader image:
  
    1.) Open ``SlimBootloader.bin`` on ``<sbl_tree>\Outputs\qemu\``
    
    2.) Goto offset ``0x18000025`` and modify it to ``0x00``, and *SAVE* the image
    
    3.) Execute |SPN| on QEMU by using the following command:
 
        - Windows::
 
            "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio  -pflash Outputs\qemu\SlimBootloader.bin

        - Linux::
 
            qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin


   .. image:: /images/ex6-5.jpg
     :alt: Compile completed
     :align: center




.. tip::

    ``BoardConfig.py`` contains lots of options for customization.  Most of the |SPN| static features and Flash image layout can be customized here.


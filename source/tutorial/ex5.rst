.. _Exercise 5:

Exercise 5 \\- \ Feature Customization - Splash
---------------

.. note::
  **In this exercise, we'll learn how to create display splash screen.**


You can execute |SPN| with the following steps:

* Modify board configuration file

  - In file ``..\SlimBoot\Platform\QemuBoardPkg\BoardConfig.py``
  
  - Change self.ENABLE_SPLASH to 0 and save the file::
      
      self.ENABLE_SPLASH = 0


* Rebuild SlimBoot by type-in cmd::

    python BuildLoader.py build qemu

* Completion: you will see ``Done [qemu]`` on the screen after compile completed

* Execute bootloader on QEMU by type-in cmd:

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio  -pflash Outputs\qemu\SlimBootloader.bin

* Check the graphics console Window to see the difference 



.. image:: /images/Ex5.jpg
   :alt: Compile completed
   :align: center


.. tip::
    * ``BoardConfig.py`` contains lots of options for customization.  Most of the SlimBoot static features and Flash image layout can be customized here.
    
    * Release QEMU control by::
    
      Ctrl+Alt+G
      
    * Exit Shell by close QEMU



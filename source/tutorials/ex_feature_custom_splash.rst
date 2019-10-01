.. _ExerciseFeatureCustomSplash:

Exercise \\- \ Feature Customization - Splash
-----------------------------------------------

.. note::
  **In this exercise, we'll learn how to enable display splash screen.**


You can execute |SPN| with the following steps:

1. Modify board configuration file

  - In file ``<sbl_tree>\Platform\QemuBoardPkg\BoardConfig.py``
  
  - Change self.ENABLE_SPLASH to 0 and save the file::
      
      self.ENABLE_SPLASH = 0


2. Rebuild |SPN| by using the following command::

    python BuildLoader.py build qemu

3. Completion: you will see ``Done [qemu]`` on the screen after compile completed

4. Execute |SPN| on QEMU by using the following command:

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio  -pflash Outputs\qemu\SlimBootloader.bin

5. Check the graphics console Window to see the difference 



.. image:: /images/ex5.jpg
   :alt: Compile completed
   :align: center


.. tip::
    
    ``BoardConfig.py`` contains lots of options for customization.  Most of the |SPN| static features and Flash image layout can be customized here.
    
    * Release QEMU control by::
    
          Ctrl+Alt+G
      
    * Exit Shell by close QEMU



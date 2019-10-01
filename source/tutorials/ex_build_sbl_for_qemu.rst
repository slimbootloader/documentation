.. _ExerciseBuildSblforQemu:

Exercise \\- \ Build |SPN| for QEMU
------------------------------------------

.. note::
  **In this exercise, we'll learn how to build SBL for QEMU emulator.**


You can build |SPN| with the following steps:

1. Launch Command Prompt
2. Go to |SPN| source code folder by using the following command::

    cd C:\slimbootloader 

3. Clean source code folder before we build code by using the following command::

    python BuildLoader.py clean

4. Build source code by using the following command::

    python BuildLoader.py build qemu 

5. Completion: you will see ``Done [qemu]`` on the screen after compile completed

.. image:: /images/ex1.jpg
   :alt: Compile completed
   :align: center
   :width: 500px
   :height: 350px

.. tip::
   If build target is changed,  it is recommended to do a clean first before build.  If source code is modified, incremental build is conducted automatically::
   
      BuildLoader.py clean
   
   By default, it builds DEBUG binary with FSP release binary.  It can be changed::  
   
      -fd: uses FSP DEBUG binary.     
   
      -r: RELEASE build

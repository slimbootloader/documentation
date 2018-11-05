.. _Exercise 8:

Exercise 8 \\- \ UEFI Payload
---------------

.. note::
  **In this exercise, we'll learn how to build Slimbootloader with specific payload.**


You can execute |SPN| with the following steps:

* Rebuild SlimBoot with specific payload, append the following line into file ``Platform/QemuBoardPkg/CfgData/CfgDataExt_Brd1.dlt`` ::

    GEN_CFG_DATA.PayloadId                     | 'UEFI'
    

* Rebuild SlimBoot by type-in cmd::

    python BuildLoader.py build qemu
    
* Completion: you will see ``Done [qemu]`` on the screen after compile completed    

* Execute bootloader on QEMU by type-in cmd:

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio -pflash Outputs\qemu\SlimBootloader.bin -drive id=mydisk,if=none,file=..\Misc\QemuImg\QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d

 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin -drive id=mydisk,if=none,file=../Misc/QemuImg/QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d
 
* Boot to UEFI Shell on graphics console 
 
  .. image:: /images/Ex8.jpg
    :alt: Compile completed
    :align: center
    

.. note::
    * Multiple payloads can be supported.  
    
    * FirmwareUpdate and OsLoader are the default embedded payloads.  
    
    * UEFI payload is a separate payload (Same as coreboot UEFI payload)



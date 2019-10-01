.. _ExerciseUefiPayload:

Exercise \\- \ UEFI Payload
-----------------------------

.. note::
  **In this exercise, we'll learn how to build SlimBootloader with specific payload.**


You can execute |SPN| with the following steps:

1. Rebuild |SPN| with specific payload, append the following line into file ``<sbl_tree>\Platform/QemuBoardPkg/CfgData/CfgDataExt_Brd1.dlt`` ::

    GEN_CFG_DATA.PayloadId                     | 'UEFI'
    

2. Rebuild |SPN| by using the following command::

    python BuildLoader.py build qemu -p "OsLoader.efi:LLDR:Lz4;UefiPld.fd:UEFI:Lzma"
    
3. Completion: you will see ``Done [qemu]`` on the screen after compile completed    

4. Execute |SPN| on QEMU by using the following command:

 - Windows::
 
    "C:\Program Files\qemu\qemu-system-x86_64.exe" -m 256M -machine q35 -serial stdio -pflash Outputs\qemu\SlimBootloader.bin -drive id=mydisk,if=none,file=..\Misc\QemuImg\QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d

 - Linux::
 
    qemu-system-x86_64 -m 256M -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin -drive id=mydisk,if=none,file=../Misc/QemuImg/QemuSata.img,format=raw -device ide-hd,drive=mydisk -boot order=d
 
5. Boot to UEFI Shell on graphics console 
 
  .. image:: /images/ex8.jpg
    :alt: Compile completed
    :align: center
    

.. note::

    \\- \Multiple payloads can be supported. 
     
    \\- \FirmwareUpdate and OsLoader are the default embedded payloads.  
    
    
    \\- \UEFI payload is a separate payload (Same as coreboot UEFI payload)



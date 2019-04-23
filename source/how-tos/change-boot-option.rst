.. _change-boot-options:

Change Boot Options
----------------------

|SPN| has a default list of boot options. It attempts to boot from the first entry. If it fails to load anything bootable, it tries the subsequent options. If none of the boot options are working, it fallbacks to shell.

#. eMMC boot partition 0
#. eMMC boot partition 1
#. SATA boot partition 0
#. USB boot partition 0



Change at Pre Build Time
^^^^^^^^^^^^^^^^^^^^^^^^^

Manually modify ``CfgData_BootOption.dsc`` and rebuild |SPN|.


Change at Post Build time
^^^^^^^^^^^^^^^^^^^^^^^^^

Use |CFGTOOL| to modify a boot option entry then stitch 
the update configuration data component in |SPN|.

See more details in :ref:`configuration-tool`.


Change at Runtime
^^^^^^^^^^^^^^^^^^^^^

If the boot option is already supported in |SPN| boot option list, you can change its values from |SPN| shell interface.


For example, to switch boot options of index 0 and 3::

    Press any key within 2 second(s) to enter the command shell

    Shell>

    Shell> boot
    Boot options (in HEX):

    Idx|ImgType|DevType|Flags|DevAddr |HwPart|FsType|SwPart|File/Lbaoffset
      0|      0|   MMC |   0 |    1C00|    0 |  FAT |    0 | iasimage.bin
      1|      0|   MMC |   0 |    1C00|    0 | AUTO |    1 | iasimage.bin
      2|      0|  SATA |   0 |    1200|    0 |  FAT |    0 | iasimage.bin
      3|      0|   USB |   0 |    1500|    0 |  FAT |    0 | iasimage.bin

    SubCommand:
      s   -- swap boot order by index
      a   -- modify all boot options one by one
      q   -- quit boot option change
      idx -- modify the boot option specified by idx (0 to 0x3)
    s
    Enter first index to swap (0x0 to 0x3)
    0
    Enter second index to swap (0x0 to 0x3)
    3
    Updated the Boot Option List
    Boot options (in HEX):

    Idx|ImgType|DevType|Flags|DevAddr |HwPart|FsType|SwPart|File/Lbaoffset
      0|      0|   USB |   0 |    1500|    0 |  FAT |    0 | iasimage.bin
      1|      0|   MMC |   0 |    1C00|    0 | AUTO |    1 | iasimage.bin
      2|      0|  SATA |   0 |    1200|    0 |  FAT |    0 | iasimage.bin
      3|      0|   MMC |   0 |    1C00|    0 |  FAT |    0 | iasimage.bin


    Shell> exit


|SPN| shall boot from USB by attempting loading IAS image ``iasimage.bin`` from partition 0. If IAS image not found, it fallbacks to loading ``vmlinuz``. If nothing is bootable, it returns to shell.


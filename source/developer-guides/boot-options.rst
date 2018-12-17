.. _boot-options:

Boot Options
--------------

|SPN| supports boot options configuration for different boot targets. This feature is designed to provide flexibility and configurability, including:

* Partition layout options (RAW, MBR, or GPT)
* File system support (FAT and Ext2/3)
* Multiple boot devices (eMMC, UFS, NVMe, SATA, USB, SPI flash etc)
* Redundant and fallback options

Boot option flow is shown in the following flow chart:

.. graphviz:: /images/boot_option.dot

A boot option entry contains the following data structure to boot OS (``OsBootOptionGuid.h``)::

    typedef struct {

      ///
      /// Image type for Image[0]. Refer BOOT_IMAGE_TYPE
      ///
      UINT8                ImageType;

      ///
      /// Zero means normal boot.
      ///
      UINT8                BootFlags;
      UINT8                Reserved;

      ///
      /// Boot medium type, Refer OS_BOOT_MEDIUM_TYPE
      ///
      UINT8                DevType;

      ///
      /// If there are multiple controllers, it indicate which 
      /// controller instance the boot medium belong to.
      ///
      UINT8                DevInstance;

      ///
      /// Zero-based hardware partition number
      ///
      UINT8                HwPart;

      ///
      /// Zero-based software partition number for boot image
      /// Used for file system only.
      ///
      UINT8                SwPart;

      ///
      /// For File system support only, Refer OS_FILE_SYSTEM_TYPE
      ///
      UINT8                FsType;

      // Image[0] is for normal boot OS
      // Image[1] is for trusty OS
      // Image[2] is for misc image
      // Image[3-6] is for extra Images
      BOOT_IMAGE           Image[7];
    } OS_BOOT_OPTION;


Depending on booting scenarios, a list of boot options can be customized at prebuild time or post build time (See :ref:`change-boot-options`).

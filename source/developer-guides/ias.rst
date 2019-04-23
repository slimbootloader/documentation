IAS Image
-----------

Booting quickly and securely is highly desirable, and in many use cases, mandatory. |SPN| is designed to boot an OS by loading and verifying a kernel image contained in IAS image format. |SPN| also supports |Multiboot Specification| compliant boot images encapsulated in an IAS image.

IAS images contain a collection of OS related binaries or files, including Linux kernels, kernel command line arguments as a text file, initram, ACPI tables, or ELF/Multiboot file formats. The binaries can be extended to other types such as splash screens image (logo) and VBT files etc.

IAS image structure consists of a header, one or more payload files and terminated with a RSA signature. The high level format of IAS image is shown below:

.. graphviz:: /images/ias_format.dot

|
|


.. |Multiboot Specification| raw:: html

   <a href="https://www.gnu.org/software/grub/manual/multiboot/multiboot.html" target="_blank">Multiboot Specification</a>


IAS image can be optionally stored in raw format on eMMC or USB partition without using EXT2 or FAT file system.
This may help boot performance. See :ref:`create-ias-boot-image` for more details.

For complete IAS image specification, visit |here|:

.. |here| raw:: html

   <a href="https://github.com/intel/iasimage/blob/master/docs/02_mcd.md" target="_blank">here</a>


.. note:: |SPN| debug build is able to boot standard Linux kernel without packing in IAS image format. See :ref:`release-build` for more details.


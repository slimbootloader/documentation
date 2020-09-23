Boot Image
----------

Booting quickly and securely is highly desirable, and in many use cases, mandatory. |SPN| OsLoader payload is designed to boot an OS by loading and verifying a kernel image 
in an |SPN| container image format. |SPN| supports |Multiboot Specification| compliant boot images encapsulated in an |SPN| boot container.

.. note:: See :ref:`gen-container-tool` for more details on container format.


.. |Multiboot Specification| raw:: html

   <a href="https://www.gnu.org/software/grub/manual/multiboot/multiboot.html" target="_blank">Multiboot Specification</a>


|SPN| container containing the boot image can be stored one of the OsLoader supported boot media. |SPN| OsLoader payload supports many different partition layouts and file systems
and can also load the boot image from a raw partition using the LBA number. 

See :ref:`create-container-boot-image` for more details.

.. note:: |SPN| **debug** build is able to boot standard Linux kernel without packing in |SPN| container image format. See :ref:`release-build` for more details.


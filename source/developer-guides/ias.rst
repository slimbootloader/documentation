IAS Image
-----------

Booting quickly and securely is highly desirable, and in many use cases, mandatory. |SPN| is designed to boot OS by directly loading and verifying a kernel image in a raw format known as IAS image.

IAS image is a container that includes kernel, initrd, command line parameters and additional data, and terminated with a RSA signature.

IAS image format can also support |Multiboot Protocol| compliant boot images.

.. |Multiboot Protocol| raw:: html

   <a href="https://www.gnu.org/software/grub/manual/multiboot/multiboot.html" target="_blank">Multiboot Protocol</a>


The high level format of IAS image is shown below:


.. graphviz:: /images/ias_format.dot

|
|

For complete IAS image specification, visit |here|:

.. |here| raw:: html

   <a href="https://github.com/intel/iasimage/blob/master/docs/02_mcd.md" target="_blank">here</a>


.. note:: |SPN| debug build is able to boot standard Linux kernel without packing in IAS image format. See :ref:`release-build` for more details.

.. note:: IAS image can be placed into raw partition. This may help boot performance.
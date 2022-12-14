.. _osloader:

OsLoader
--------

Introduction
============

OsLoader is a tightly-coupled payload for Slim Bootloader that natively supports the Linux Boot Protocol \
and is also capable of launching several different executable file formats (Multiboot ELF, ELF, PE32, UEFI-PI FV).

If a payload is not specified in the SBL build command, OsLoader will be the default payload built with SBL.

OsLoader expects the boot image to be packaged as an SBL Container. OsLoader verifies the boot image for secure boot \
purposes. Refer to the :ref:`Container Tool <gen-container-tool>` document for more details on the Container format, \
and :ref:`Create Container Boot Image <create-container-boot-image>` document for how to create a container image.

OsLoader can launch the Linux kernel directly when debug mode is enabled.

OsLoader Boot Flow
==================

The flowchart below explains the boot flow when launching an OS using OsLoader.

.. image:: /images/osldr_flow.PNG
   :width: 750px

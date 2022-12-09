.. _gen-container-tool:

Container Tool
--------------

``GenContainer.py`` is a tool used to generate the container images in a binary file format.

A container is an encapsulation of multiple components as depicted in the following image:

.. image:: /images/Cont.PNG
   :alt: Container structure

.. _container-formats:

Image Types
===========

Normal
^^^^^^

This type of container contains a single image in it. Image format can be ELF, Multiboot, Multiboot-2, UEFI-PI FV, or PE32.

Classic
^^^^^^^

This image type is used to boot a typical Linux image. This image format combines a kernel command line and the kernel image.
Optionally more files like an initrd, ACPI tables, firmware files could be added. 

The kernel command line, kernel image, and the optional initrd are in a **fixed order**.
  * Dummy files need to be provided if one of the component is not in use. 
  * For example, if initrd is not used, a dummy file needs to be provided in place of the initrd.

**File Order:** cmdline.txt, bzImage (kernel), initrd, acpi, firmware1, firmware2, ...

The classic container's format is laid out below.

  .. image:: /images/sbl_classic_container.png
      :width: 600px

Multiboot ELF
^^^^^^^^^^^^^

This type of container stores Multiboot compliant ELF images and their corresponding command lines in pairs. The first ELF image \
in the Multiboot image is assumed to be the one used for booting. If an image does not use a command line, a dummy file needs to be \
provided in place of the command line file.

**Files:** cmdline1, elf1, cmdline2, elf2, ...

.. note::
    **The default container type is Classic.**

Tool Usage
==========

Following operations are supported::

    usage: GenContainer.py [-h] {view,create,extract,replace,sign} ...

    positional arguments:
      {view,create,extract,replace,sign}
                            command
        view                display a container image
        create              create a container image
        extract             extract a component image
        replace             replace a component image
        sign                compress and sign a component image

    optional arguments:
      -h, --help            show this help message and exit

* view::

    usage: GenContainer.py view [-h] -i IMAGE

    optional arguments:
      -h, --help  show this help message and exit
      -i IMAGE    Container input image

 - example::

    python GenContainer.py view -i ContainerImage.bin

* create::

    usage: GenContainer.py create [-h] (-l LAYOUT | -cl COMP_LIST [COMP_LIST ...])
                                  [-t IMG_TYPE] [-o OUT_PATH] [-k KEY_PATH]
                                  [-cd COMP_DIR] [-td TOOL_DIR]
                                  [-a {SHA2_256, SHA2_384, RSA2048_PKCS1_SHA2_256, RSA3072_PKCS1_SHA2_384, RSA2048_PSS_SHA2_256, RSA3072_PSS_SHA2_384,  NONE}]

    optional arguments:
      -h, --help            show this help message and exit
      -l LAYOUT             Container layout intput file if no -cl
      -cl COMP_LIST [COMP_LIST ...]
                            List of each component files, following XXXX:FileName format
      -t IMG_TYPE           Container Image Type : [NORMAL, CLASSIC, MULTIBOOT]
      -o OUT_PATH           Container output directory/file
      -a {SHA2_256,
          SHA2_384,
          RSA2048_PKCS1_SHA2_256,
          RSA3072_PKCS1_SHA2_384,
          RSA2048_PSS_SHA2_256,
          RSA3072_PSS_SHA2_384,
          NONE}
                            Authentication algorithm
      -k KEY_PATH           KEY_ID or Private key file
      -cd COMP_DIR          Componet image input directory
      -td TOOL_DIR          Compression tool directory
      -s  SVN               Security version number for Component for  no -cl option


 - example::

    python GenContainer.py create -cl CMDL:cmdline.txt:$svn KRNL:vmlinuz:$svn INRD:initrd:$svn -o Out

    $svn is optional

    or

    python GenContainer.py create -l layout.txt -o Out

.. note::

    layout.txt can look like following::

      # Container Layout File
      #
      #    Name ,  ImageFile      ,CompAlg  ,  AuthType,       KeyFile                 , Alignment,  Size,     Svn
      # ============================================================================================================
        ( 'BOOT', 'Out'           , ''      , 'RSA2048_PSS_SHA2_256', 'CONTAINER_KEY_ID'        ,  0,     0,    0),  <--- Container Hdr
        ( 'CMDL', 'cmdline.txt'   , 'Lz4'   , 'RSA2048_PSS_SHA2_256', 'CONTAINER_COMP_KEY_ID'   ,  0,     0,    0),  <--- Component Entry 1
        ( 'KRNL', 'vmlinuz'       , 'Lz4'   , 'RSA2048_PSS_SHA2_256', 'CONTAINER_COMP_KEY_ID'   ,  0,     0,    0),  <--- Component Entry 2
        ( 'INRD', 'initrd'        , 'Lz4'   , 'RSA2048_PSS_SHA2_256', 'CONTAINER_COMP_KEY_ID'   ,  0,     0,    0),  <--- Component Entry 3

    If you provide the full path or a file/dir name to output or key, in both layout.txt and command line,
    command line options will always overwrite the values in layout.txt.


* extract::

    usage: GenContainer.py extract [-h] -i IMAGE [-n COMP_NAME] [-od OUT_DIR]
                                  [-td TOOL_DIR]

    optional arguments:
      -h, --help    show this help message and exit
      -i IMAGE      Container input image path
      -n COMP_NAME  Component name to extract
      -od OUT_DIR   Output directory
      -td TOOL_DIR  Compression tool directory
 
 - example::

    python GenContainer.py extract -i ContainerImage.bin -od ExtDir

* replace::

    usage: GenContainer.py replace [-h] -i IMAGE [-o NEW_NAME] -n COMP_NAME -f
                                  COMP_FILE [-c {lz4,lzma,dummy}] [-k KEY_FILE]
                                  [-od OUT_DIR] [-td TOOL_DIR]

    optional arguments:
      -h, --help           show this help message and exit
      -i IMAGE             Container input image path
      -o NEW_NAME          Container new output image name
      -n COMP_NAME         Component name to replace
      -f COMP_FILE         Component input file path
      -c {lz4,lzma,dummy}  compression algorithm
      -k KEY_FILE          KEY_ID/Private key file path to sign component
      -od OUT_DIR          Output directory
      -td TOOL_DIR         Compression tool directory
      -s  SVN              Security version number for Component

 - example::

    python GenContainer.py replace -i ContainerImage.bin -od Out -n CMDL -f new_cmdline.txt

* sign::

    usage: GenContainer.py sign [-h] -f COMP_FILE [-o SIGN_FILE]
                                [-c {lz4,lzma,dummy}] [-a {SHA2_256, SHA2_384, RSA2048_PKCS1_SHA2_256, RSA3072_PKCS1_SHA2_384, RSA2048_PSS_SHA2_256, RSA3072_PSS_SHA2_384, NONE}]
                                [-k KEY_FILE] [-od OUT_DIR] [-td TOOL_DIR]

    optional arguments:
      -h, --help                show this help message and exit
      -f COMP_FILE              Component input file path
      -o SIGN_FILE              Signed output image name
      -c {lz4,lzma,dummy}       compression algorithm
      -a {SHA2_256,
          SHA2_384,
          RSA2048_PKCS1_SHA2_256,
          RSA3072_PKCS1_SHA2_384,
          RSA2048_PSS_SHA2_256,
          RSA3072_PSS_SHA2_384,
          NONE}
                                Authentication algorithm
      -k KEY_FILE               KEY_ID or Private key file path to sign component
      -od OUT_DIR               Output directory
      -td TOOL_DIR              Compression tool directory

 - example::

    python GenContainer.py sign -f <ComponentImage/ContainerImage.bin> -c lz4 -td <path-to-Lz4Compress.exe>

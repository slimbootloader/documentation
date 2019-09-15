.. _build-steps:


|SPN| Build Steps
=================

See :ref:`host-setup` on how to setup build environment for building |SPN|.


.. important:: Behind firewall? See :ref:`misc_setup_Proxy` first!


Download |SPN|
----------------

Source code is available on GitHub::

  git clone https://github.com/slimbootloader/slimbootloader.git
  cd slimbootloader


Build |SPN|
------------

|SPN| is built using the BuildLoader.py script::

    python BuildLoader.py <subcommand> <target> <options>

    <subcommand>  : build or clean
    <target>      : board name (e.g. apl or qemu)


  Example: python BuildLoader.py build qemu


For more details on the build tool, see :ref:`build-tool`.


Build Outputs
~~~~~~~~~~~~~~

If the build is successful, ``Outputs`` folder will contain the build binaries. One of the output files will be ``Stitch_Components.zip`` which will be 
used in the stitching step.


Clean
-------

Clean command removes all the existing build artifacts.

::
  
  python BuildLoader.py clean 


Stitch IFWI
------------

Stitching an IFWI with SBL requires certain other ingredients. Please refer to :ref:`supported-hardware` for platform specific stitching details.


Flash IFWI
-----------

The final step is to flash the stitched IFWI image on the target board. 

.. note:: Typically a flash programmer like `DediProg <https://www.dediprog.com//>`_ would be required for this step. 
.. note:: Linux users please refer to `DediProg Linux User Manual <https://www.dediprog.com/download/save/727.pdf>`_. 


Please also refer to :ref:`supported-hardware` for platform specific details.

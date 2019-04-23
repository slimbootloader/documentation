.. _create-new-payload:

Create New Payload
---------------------------

.. note:: Before you decide to support a new payload in |SPN|, it is recommended to check whether the existing payloads can be updated to support the new requirement.


For **tightly-coupled** payload, two steps are required to integrate a new payload:

#. Create a new payload starts with adding a new module in ``PayloadPkg/<payload_bar>`` with entry point function ``PayloadMain()``.

   See :ref:`package-dependency` when you are implementing payload code.


#. Build and integrate the new payload

    The image size and memory location of the new payload can be configured in ``BoardConfig.py``. The following values are used in |APL| payload configurations::

        PAYLOAD_SIZE         = 0x0001F000
        EPAYLOAD_SIZE        = 0x00120000
        LOADER_RSVD_MEM_SIZE = 0x00B8C000
        PLD_RSVD_MEM_SIZE    = 0x00500000
        PAYLOAD_LOAD_HIGH    = 1


For **loosely-coupled** payload, you are full control of payload design and implementation.

UEFI Payload is loosely-coupled payload. 


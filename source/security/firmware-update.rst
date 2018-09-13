Firmware Update
------------------

|SPN| implements a robust, secure and power fail-safe firmware update mechanism. |SPN| image can be built to contain redundant boot components and depending on hardware assisted boot partition switch, to support fail-safe update.

If firmware update is interrupted by a power failure and one boot partition is corrupted, |SPN| boots from the alternate partition to avoid bricking the platform. The firmware update authenticates the update image (a.k.a. capsule) before updating the firmware.

Firmware update feature is implemented as a |SPN| payload.

When firmware update is signalled, Stage 2 loads firmware update payload to start update flow. During the update, firmware update playload keeps a state machine to keep track of the update progress as follows:


#. Boot from partition A
#. If update flow is requested, load FWU payload
#. FWU loads and verifies capsule data. If successful, update partition B
#. Set partition B as 'active'
#. Reboot
#. Boot from partition B
#. If update flow is in progress, load FWU payload
#. FWU loads and verifies capsule data. If successful, update partition A
#. Set partition A as 'active'
#. End update flow state machine and reboot



Triggering Firmware Update 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Triggering firmware update is a platform specific mechanism. The location of the firmware update capsule image is passed to Firmware update payload through configuration data.

To generate and sign firmware update capsule, see :ref:`create-capsule`.

Firmware update can be triggered from OS or from |SPN| shell. See :ref:`trigger-update-from-shell`.

.. note:: Capsule update defined by UEFI specification is different from |SPN| capsule format.



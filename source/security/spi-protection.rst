.. _spi-protection:

Flash Protection
======================

To prevent unauthorized changes to the firmware, the flash media is write-protected before |SPN| transfering control to the OS. This write-protection is enabled payload stage (e.g., OS loader).

If external payload (e.g., UEFI payload) is used, external payload is responsible for locking down flash write-protection before launching OS.


.. _smm-disable:

System Management Mode
=========================

|SPN| does not support SMM. SMI may not be suitable for real-time and safe-critical systems.

|SPN| disables all SMI sources and locks the configuration by default. For platforms requires SMM support, payload is responsible for enabling SMM support and locking down the configuration.







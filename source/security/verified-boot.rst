Verified Boot
--------------

The initial Root of Trust (RoT) provides the anchor of trust for the platform and is typically rooted in hardware.
The chain of trust is maintained by cryptographically verifying each subsequent component before it is executed. If the verification of a component fails, the boot process will be halted.

Verified boot ensures all executed code comes from a trusted source. |SPN| supports verified boot.

To enable verified boot, see :ref:`enable-verified-boot`.



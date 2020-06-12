Verified Boot
--------------

The initial Root of Trust (RoT) provides the anchor of trust for the platform and is typically rooted in hardware.
The chain of trust is maintained by cryptographically verifying each subsequent component before it is executed. If the verification of a component fails, the boot process will be halted.

Verified boot ensures all executed code comes from a trusted source. |SPN| supports verified boot.

Below picture depicts how |SPN| maintains chain-of-trust as platform boots across various stages:

.. image:: /images/sec_chain_of_trust.jpg
   :alt: Security Chain-of-Trust

.. note:: Secure Chain-of-Trust for ApolloLake platform differs slightly from the above picture.

To enable verified boot, see :ref:`enable-verified-boot`.



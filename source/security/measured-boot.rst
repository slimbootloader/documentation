Measured Boot
--------------

Measures firmware components and records them into a platform storage device such as Trusted Platform Module (TPM) or Intel® Platform Trust Technology (Intel® PTT). The recorded measurement can be compared with a golden value, i.e. the expected unique measurement that was calculated on a known, good system. If the measurement does not match the golden measurement the system integrity is considered compromised.

The integrity of a remote system can be ascertained by comparing the measurement reported by the system to the golden value.

|SPN| implements measured boot and supports both discrete TPM device or Intel® PTT (Platform Trusted Technology).


.. note:: Measured boot should be enabled in conjunction with verified boot to achieve firmware security.

.. note:: Measured boot feature is not enabled in |SPN| default build. See :ref:`pre-build` on how to enable it.

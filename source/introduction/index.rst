Introduction
=============

.. epigraph::

  `The art of simplicity is a puzzle of complexity.` -- **Douglas Horton**


Design Philosophy
-------------------

Platform firmware has two primary responsibilities:

* **Initializing the hardware**
* **Booting an Operating System**

Designing platform firmware can be monolithic combining hardware initialization and boot functionality, *OR* it can take a modular and staged boot flow. The choice of the design depends on system requirements.

Separating initialization and boot logic is desirable for certain device classes, for example, IoT devices, as it provides the flexibility for unique use cases. A good example is the choice of operating system used in IoT devices - it is typical to deploy OS having unique boot requirements. The OS may vary from standards based like Windows using UEFI to embedded OS or RTOS using OS specific boot protocols.

|PN| (|SPN|) is designed with the modular approach by providing hardware initialization, then launching a *payload* to boot OS.


Features
------------

|PN| is designed to be:

* **Small**

* **Fast**

* **Secure**

* **Extensible**

* **Configurable**


In addition, it provides built-in features:

* **Multiple OS Support**

* **Firmware Update**

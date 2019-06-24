.. _host-setup:

Build Environment
---------------------

|SPN| build is supported on both Windows and Linux environments


.. _running-on-linux:

Building on Linux
^^^^^^^^^^^^^^^^^^^^

Supported environment: **Ubuntu Linux 18.04 LTS**

Install the following software:

* GCC 7.3 or newer
* Python 2.7
* IASL 20160422
* NASM
* OpenSSL


Build Tools Download - Ubuntu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Install required packages on Ubuntu::

  $ sudo apt-get install -y build-essential iasl python uuid-dev nasm openssl gcc-multilib qemu


Build using Dockers (Optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can also consider Dockers containers to build |SPN|. See :ref:`misc_setup_docker` for more details.



.. _running-on-windows:

Building on Windows
^^^^^^^^^^^^^^^^^^^^^

Supported environment: **Microsoft Visual Studio 2015**

Install the **exact** versions (if specified) of the following tools to the designated directories:

* Python 2.7 - **C:\\Python27**
* IASL 20160422 - **C:\\ASL**
* NASM - **C:\\Nasm**
* OpenSSL - **C:\\openssl**     


Build Tools Download - Windows
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Python 2.7 - 64 bit version. 

|https://www.python.org/downloads/release/python-2713/|

.. |https://www.python.org/downloads/release/python-2713/| raw:: html

   <a href="https://www.python.org/downloads/release/python-2713/" target="_blank">https://www.python.org/downloads/release/python-2713/</a>

**Require:**  v2.7.13 is require version

.. note::
  Add Python to the PATH


IASL 20160422-64 

|https://acpica.org/sites/acpica/files/iasl-win-20160422.zip|

.. |https://acpica.org/sites/acpica/files/iasl-win-20160422.zip| raw:: html

   <a href="https://acpica.org/sites/acpica/files/iasl-win-20160422.zip" target="_blank">https://acpica.org/sites/acpica/files/iasl-win-20160422.zip</a>

unzip then copy files to C:\\asl

**Require:** Install to C:\\Asl


Nasm 2.11

|https://www.nasm.us/pub/nasm/releasebuilds/2.11.08/|

.. |https://www.nasm.us/pub/nasm/releasebuilds/2.11.08/| raw:: html

   <a href="https://www.nasm.us/pub/nasm/releasebuilds/2.11.08/" target="_blank">https://www.nasm.us/pub/nasm/releasebuilds/2.11.08/</a>

**Require:** Install to C:\\Nasm


Openssl (latest)

Download from |https://indy.fulgan.com/SSL| (the latest version:  |https://indy.fulgan.com/SSL/openssl-1.0.2-x64_86-win64.zip|)

.. |https://indy.fulgan.com/SSL| raw:: html

   <a href="https://indy.fulgan.com/SSL" target="_blank">https://indy.fulgan.com/SSL</a>


.. |https://indy.fulgan.com/SSL/openssl-1.0.2-x64_86-win64.zip| raw:: html

   <a href="https://indy.fulgan.com/SSL/openssl-1.0.2-x64_86-win64.zip" target="_blank">https://indy.fulgan.com/SSL/openssl-1.0.2-x64_86-win64.zip</a>

 unzip then copy files to C:\\Openssl 

**Require:** Install to C:\\Openssl

.. note::
  Set environment variable OPENSSL_PATH to openssl directory,
  Cmd: set OPENSSL_PATH=C:\\Openssl


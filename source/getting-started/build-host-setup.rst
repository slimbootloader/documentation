.. _running-on-linux:

Building on Linux
---------------------

Supported environment: **Ubuntu Linux 18.04 LTS**

Install the following software:

* GCC 7.3 or newer
* Python 2.7
* IASL 20160422
* NASM
* OpenSSL

You can also consider Docker containers to build |SPN|. See :ref:`build-on-docker` for more details.


.. note:: Python3 is not supported.



.. _running-on-windows:

Building on Windows
---------------------

Supported environment: **Microsoft Visual Studio 2015**

Install the **exact** versions (if specified) of the following tools to the designated directories:

* Python 2.7 - **C:\\Python27**
* IASL 20160422 - **C:\\ASL**
* NASM - **C:\\Nasm**
* OpenSSL - **C:\\openssl**     


Python 2.7 - 64 bit version. 

|https://www.python.org/downloads/release/python-2713/|

.. |https://www.python.org/downloads/release/python-2713/| raw:: html

   <a href="https://www.python.org/downloads/release/python-2713/" target="_blank">https://www.python.org/downloads/release/python-2713/</a>

**Require:**  v2.7.13 is require version


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



.. _proxy-settings:

Proxy Settings
----------------------------------------------------

If your build host is behind company's firewall, it is important to set up proxy correctly otherwise building |SPN| would fail.

On Linux::

    export HTTP_PROXY=http://<proxy_host>:<port>
    export HTTPS_PROXY=https://<proxy_host>:<port>

On Windows::

    set HTTP_PROXY=http://<proxy_host>:<port>
    set HTTPS_PROXY=https://<proxy_host>:<port>

Cloning repository behind firewall requires git proxy configuration::

    git config --global http.proxy http://<proxy_host>:<proxy_port>


.. _build-on-docker:

Using Dockers To Build
--------------------------

**Step 1: Download Docker**

Install docker package::

  sudo apt-get install docker.io

Add yourself to the docker group::

  sudo usermod -aG docker $USER

Log out then re-login to Ubuntu


.. note:: If you are behind firewall, see |Docker Proxy Settings|.

.. |Docker Proxy Settings| raw:: html

   <a href="https://docs.docker.com/config/daemon/systemd/#httphttps-proxy" target="_blank">Docker Proxy Settings</a>


**Step 2: Build Docker Image**

Build docker image using Dockerfile::

  cd <slimboot_source_tree>
  docker build -t sbl --network=host .

**Step 3: Start Docker Container**

Run the container in the background::

  cd <slimboot_source_tree>
  docker run -it --rm --network=host --name=sbl -d -v $PWD:/work sbl


**Step 4: Build Inside Docker Container**

Build QEMU |SPN| inside running container::

  docker exec -w /work sbl python BuildLoader.py build qemu


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

* |cxFreeze 4.3.3| - default installation path
* Python 2.7 - **C:\\Python27**
* IASL 20160422 - **C:\\ASL**
* NASM - **C:\\Nasm**
* OpenSSL - **C:\\openssl**

.. |cxFreeze 4.3.3| raw:: html

   <a href="https://sourceforge.net/projects/cx-freeze/files/4.3.3/" target="_blank">cxFreeze 4.3.3</a>
      

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

Log out then relogin to Ubuntu


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


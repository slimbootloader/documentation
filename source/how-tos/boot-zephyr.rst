.. _boot-zephyr:

Boot Zephyr
-----------------

We may follow below steps to setup Zephyr with |SPN| on |UP2| maker board and QEMU.

|UP2| Board
^^^^^^^^^^^^^^^^^

1. Follow |Getting Started Guide| to setup **Zephyr** build/dev environment

.. |Getting Started Guide| raw:: html

   <a href="https://docs.zephyrproject.org/latest/getting_started/getting_started.html" target="_blank">Getting Started Guide</a>

2. Build an application uses synchronization sample application:

  #. setup zephyr environment::
  
        source zephyr-env.sh
        
        or 
        
        zephyr-env.cmd

  #. Build sample application for |UP2| board::
  
        cd samples/synchronization
        mkdir build_up2 && cd build_up2
        cmake -GNinja -DBOARD=up_squared_sbl ..
        ninja

     Output file: ``samples/synchronization/build_up2/zephyr/zephyr.elf``

3. Build |SPN| image with zephyr.elf as a direct payload for simple test. 

  - build |PN| for |UP2| board with the built zephyr.elf::
  
        python BuildLoader.py build apl -p <zephyr_root>/samples/synchronization/build_up2/zephyr/zephyr.elf


4. Create a IFWI for |UP2|, follow the steps |here|.

.. |here| raw:: html

   <a href="https://slimbootloader.github.io/supported-hardware/up2.html#stitching" target="_blank">here</a>

5. Flash IFWI and check the zephyr up & running thru serial console::

    ......
    Stage2 heap: 0xB4C000 (0x10C000 used, 0xA40000 free)
    Payload ent***** Booting Zephyr OS zephyr-v1.13.0-1689-g4a7c422182 *****
    threadA: Hello World from up_squared!
    threadB: Hello World from up_squared!
    threadA: Hello World from up_squared!
    threadB: Hello World from up_squared!
    threadA: Hello World from up_squared!


QEMU
^^^^^^^^^

1. Build an application uses synchronization sample application:
  
  #. setup zephyr environment::
  
        source zephyr-env.sh
        
        or 
        
        zephyr-env.cmd

  #. Build sample application for QEMU::

        cd samples/synchronization
        mkdir build_qemu && cd build_qemu
        cmake -GNinja -DBOARD=qemu_x86 ..
        ninja

     Output file: ``samples/synchronization/build_qemu/zephyr/zephyr.elf``

2. Build |SPN| image with zephyr.elf as as payload for simple test. 

  Build |SPN| to include zephyr.elf::

        python BuildLoader.py build qemu -p <zephyr_root>/samples/synchronization/build_qemu/zephyr/zephyr.elf

3. Run QEMU and check the zephyr up & running thru serial console : 

  #. Execute QEMU::
    
        qemu-system-x86_64 -m 256M -machine q35 -nographic -pflash Outputs/qemu/SlimBootloader.bin

  #. Check result thru serial console::

        ......
        Payload entry: 0x00001000
        Jump to payload
        ***** Booting Zephyr OS zephyr-v1.13.0-1689-gbc34b1aa09 *****
        threadA: Hello World from qemu_x86!
        threadB: Hello World from qemu_x86!
        threadA: Hello World from qemu_x86!

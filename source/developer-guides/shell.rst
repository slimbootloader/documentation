Shell Interface
----------------

|SPN| comes with an built-in shell interface for diagnosis and debugging purpose. It allows one to examine platform state (e.g., dump memory content, PCI configuration registers, etc.), change boot configuration and trouble shoot before launching OS.

Developers can also add their own shell commands for unit testing.

To enter shell interface, press any key after reboot and before OS is launched.

Built-in shell commands::

  Shell> help
  exit     - Exit the shell
  help     - List supported commands
  hob      - List HOBs
  mem      - Read or write system memory
  mmap     - Display memory map
  perf     - Display performance data
  boot     - Print or modify the OS boot option list
  cpuid    - Read CPU specific information
  io       - Read or write I/O ports
  msr      - Read or write model specific registers
  mtrr     - Display current MTRR configuration
  pci      - Display PCI devices
  reset    - Reset the system
  ucode    - Display microcode version
  fwupdate - Initiate Firmware Update

Use '-h' to get help message for a command.

.. note:: For small image footprint or security reasons, one can exclude shell module from |SPN| in release builds.


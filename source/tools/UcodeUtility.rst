.. _ucode-utility:

uCode Utility
-------------

``UcodeUtility.py`` generates a microcode binary for use with firmware updates.

Command Syntax::

    usage: UcodeUtility.py [-h] -s SLOT_SIZE -i INPUT_FILE_NAMES [INPUT_FILE_NAMES ...] -o OUTPUT_FILE_NAME

    optional arguments:
    -h, --help            show this help message and exit
    -s SLOT_SIZE, --slot-size SLOT_SIZE
                            Specify the ucode slot size (in bytes).
    -i INPUT_FILE_NAMES [INPUT_FILE_NAMES ...], --input_file_names INPUT_FILE_NAMES [INPUT_FILE_NAMES ...]
                            Specify the ucode file names (*.pdb files).
    -o OUTPUT_FILE_NAME, --output_file_name OUTPUT_FILE_NAME
                            Specify an output file name.



It is expected that this microcode binary be integrated into a firmware update capsule (see :ref:`firmware-update`).



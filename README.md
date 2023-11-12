
# HW/SW Codesign - Main Task Assignment


This is the template project of the HW/SW build environment for the main task.
It should contain the following files and directories (some of which are only 
created during the build process or will be added by you).

```
maintask
  |- quartus
     |- Makefile
     |- .qpf .qsf                 Quartus project files
     |- .qsys                     Platform Designer system
     |- .sdc                      Timing constraint file
     |- .tcl                      Platform Designer custom components (not created yet)
  |- software
     |- Makefile
     |- settings.bsp              The board support package (BSP) specification file
     |- src                       All software source files
     |- bsp                       The automatically created BSP
     |- build                     object/ELF file(s) of your project
     |- opencv                    A simple cmake project to compile the software
     |                            renderer for the desktop
     |- filter_images.py          A simple Python script that processes the of output
     |                            the raytracer and writes dumped images to PNG files
     |- compare_images            A script to compare two images used for the value check
  |- vhdl                         your VHDL code goes here
  |- ips                          IP files needed for the design (don't touch)
  |- Makefile                     master Makefile
  |- rpa_shell.py                 Helper script to access the Remote-Lab
  |- maintask.pdf             The assignment document
  |- coding_guidelines.pdf     The VHDL coding and design guidelines used in this course
  |- README
```

## Hardware Project

The Quaruts project and related files are located in the `quartus` directory.
The makefile in this directory provides the following targets:

| Target | Description |
|--|--|
| `all` (default) | Runs the Quartus synthesis (which also includes the Platform Designer system generation) without starting the GUI|
| `download` | Downloads the SOF file to the board |
| `quartus_gui` | Starts the Quartus GUI and loads the Quartus project |
| `qsys_gui` | Starts the Platform Designer GUI and loads the Platform Designer project |
| `clean` | Deletes all files which are generated during the build process. REMEMBER to clean your project before submission!! |

Hence, to, e.g., download the generated SOF file to the FPGA board, run the following command inside the `quartus` folder.

```
make download
```

Before the first build please make sure that the search path of the Platform Designer points to the `ips` directory.
Note that you can also start the synthesis and download process using the 
Quartus GUI.
The VHDL code of your submission MUST be placed in the ./vhdl directory. 
Don't rename any of the existing files!


## Software Project

The software project is located in the `software` directory.
The makefile in this folder builds the BSP- and application project and provides the following targets:

| Target | Description |
|--|--|
| `all` (default) | Creates the BSP and application makefiles (if necessary) and builds the ELF file. No download is performed. |
| `edit_bsp` | Opens the BSP settings GUI editor (for settings.bsp) |
| `download` | Downloads the ELF file to the Nios II processor |
| `download_sof` | Downloads the SOF file generated by the Quartus synthesis |
| `term` | Starts the nios2-terminal (JTAG UART) and connects to the Nios II processor |
| `run` | Builds and downloads the ELF file and starts nios2-terminal (JTAG UART). Combination of `download` and `term`. |
| `clean` | Deletes all files, which are generated during the build process. REMEMBER to clean your project before submission!! |
| `value_check` | Creates a reference image using the software renderer on the PC and compares it to an image created on the hardware. The FPGA must already be programmed. (`make download_sof`) |

In order to make it easier to work with the Remote-Lab the makefile also provides special targets prefixed with the term `remote_`.

| Target | Description |
|--|--|
| `remote_value_check` | Perform the same operation as the `value_check` target, but runs the software in the Remote-Lab. The FPGA in the must already be programmed (`make remote_download_sof`) |
| `remote_download` | Downloads the ELF file to the Nios system running in the remote lab (i.e., the FPGA must already by programmed, use make `remote_download_sof` for that purpose) |
| `remote_download_sof` | Downloads the SOF file generated by the Quartus synthesis to an FPGA board in the Remote-Lab |
| `remote_term` | Starts the nios2-terminal (JTAG UART) and connects to the Nios II processor running in the Remote-Lab|
| `remote_run` | Combination of `remote_download` and `remote_run` |

For all `remote_*` you must already have an active connection to the Remote-Lab, i.e., `rpa_shell.py` must be running in another shell.

Note that you can pass the `-s vga` command line argument to `rpa_shell.py` in order to open the stream showing the VGA output of the board. 

All your C source/header files MUST be placed in the `software/src` directory.
Make sure that you do not change any of the functionality implemented in the main file!
Furthermore, don't change the sw_renderer, as it is needed evaluate your solution!

## Submission
To create an archive for submission use the master makefile located in the root directory of the repository and use the `submission` target.
This creates a file called `submission.tar.gz`, which you can upload in TUWEL. 
If you are working on your own computer make sure that the build also works on the TILab computers or in the VM!

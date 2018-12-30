# NES Assembly Language Demo

## About

The goal of this project is to provide a skeleton for developing games
to run on the Nintendo Entertainment System, or more likely, one of the
many emulators of that platform.

The demo performs the minimum functions required to display something on
the screen; in its current incarnation, it simply displays a solid color
background.


## Building

This program was developed using Ubuntu Linux and the **cc65** toolchain
for targeting the 6502 clone employed by the NES. The toolchain can be
installed from the standard package repository as follows:

```bash
    sudo apt install -y build-essential cc65 fceux
```

The preceding command has been tested on Ubuntu 18.04 but should work
on any Debian-based distribution. In addition to the standard build tools,
the above command installs the 6502 cross-compilation environment as well
as the NES emulator, fceux.

Once the toolchain has been installed, the demo can be built and run in
on step using the following command:

```bash
    make run
```


## Acknolwedgements

This demo is based upon resources posted by various contributors on the
[NESDev Wiki](http://wiki.nesdev.com/w/index.php/Nesdev_Wiki). Thanks are
due to all the contributors, who have spent countless hours helping
hobbyists such as myself learn how the system works.


## Author

Thomas R. Dial <dialtr@gmail.com>


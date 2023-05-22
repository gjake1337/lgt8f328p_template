# LGT8F328P TEMPLATE

Author: Jake Goodwin
Creation Date: 2023


## Descripton:

This repo is a project template for working on the LGT8fX series of micro
controllers. Specifically the 328p version.

### Directory structure:

The directory is broken up into:

- src: where all your source code will live \*.c \*.cpp etc
- include: This is where the header files for all the source files is.
- build: All object, hex, eep, lls, map and elf files are put into this dir
- Makefile: Handles the building and programming of the controllers.
- Unity: This is for unit testing the project.
- tdd.sh: This script automatically adds dirs and files for unit tesing
- tests: this is where all the actual test dirs and files are put.
- ignored: a place to store unused stuff for the moment.

## Building:

To build the project simply use the existing *MakeFile* in the root dir like
so 

```sh
make -f ./Makefile all
```

### Flashing using an LarduinoISP

```sh
make -f ./Makefile flash_lgt8f328p
```


## Useful Tools:

- avrdude 7.0+, versions like 6.3 (2017) won't have support for the mcu
- clangd, LSP server that you can use with vim/emac/anything.
- bear, lets you generate the needed compile_commands.json for clangd.
- vim, do I really have to say this?
- avr-gcc, needed to compile it.


## Programmers:

So far I've only tested using the LarduinoISP as you can't flash the lgt8fX
chips using the usbasp programmer so far as I know. If you want to make your
own deticated programer I would recommend taking another lgt8f328p and then
putting the ISP software onto it.

Once that has been done you can solder some multistranded silicone insulated 
wire along with a 5-pin header and have a nice programming cable. Toss on 
some heat shrink to protect it and you have a programmer for less than 75 cents.




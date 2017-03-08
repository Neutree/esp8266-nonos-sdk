# Feature
* based on espressif nonos sdk v2.0
* integrate esptool and set default download baudrate as 1500000
* driver and project can be built directly at you first get this project

# How To Use
* [install docker](https://docs.docker.com/engine/installation/)
* create container(set up compile environment and download tool etc.)

pull docker image:
```
docker pull neucrack/esp-build
or
docker pull daocloud.io/neucrack/esp-build
```
plug in you device(eg:node mcu)
create a container
```
docker run -ti --name esp8266-builder --device /dev/ttyUSB0:/dev/ttyUSB0 -v dir:/build neucrack/esp-build /bin/bash
```
> the `dir` is the direction of esp8266-nonos-sdk project
when pull and run completed, the next time you want use this container by
```
docker start esp8266-builder
docker attach esp8266-builder
```

* build project and download to board
run in container
```
cd /build/esp8266-nonos-sdk
make flash
```
> build options:
```
make           : compile project
make flash     : compile and upload code to flash of board
make erase     : erase all data in flash
make monitor   : serial monitor tool
make clean     : clean binary files
make distclean : clean binary files and folders
make help      : help info
```
parameters:
```
(1) ESPPORT
	Default:/dev/ttyUSB0
(2) DOWNLOADBAUD
	Default:1500000
(3) COMPILE
    Possible value: gcc
    Default value: gcc
    If set null, will use xt-xcc.
(4) BOOT
    Possible value: none/old/new
      none: no need boot
      old: use boot_v1.1
      new: use boot_v1.2+
    Default value: new
(5) APP
    Possible value: 0/1/2
      0: original mode, generate eagle.app.v6.flash.bin and eagle.app.v6.irom0text.bin
      1: generate user1
      2: generate user2
    Default value: 1
(6) SPI_SPEED
    Possible value: 20/26.7/40/80
    Default value: 40
(7) SPI_MODE
    Possible value: QIO/QOUT/DIO/DOUT
    Default value: DIO
(8) SPI_SIZE_MAP
    Possible value: 0/2/3/4/5/6
    Default value: 2
For example:
    make COMPILE=gcc BOOT=new APP=1 SPI_SPEED=40 SPI_MODE=DIO SPI_SIZE_MAP=2
You can also use gen_misc to make and generate specific bin you needed.
    Linux: ./gen_misc.sh
    Windows: gen_misc.bat
    Follow the tips and steps by steps.
```
* monitor serial output
use serial monitor:</br>
when **linux** ,use `minicom` or `screen`
use `minicom`
```
sudo apt install minicom
sudo minicom -s  (setting /deb/ttyUSB0 115200 8n1)
sudo minicom -c on
```
exit minicom:</br>
<kbd>ctrl+A</kbd> -> <kbd>X</kbd> -> <kbd>Enter</kbd></br>
or use `screen`
```
screen /dev/ttyUSB0 115200
```
exit screen:</br>
<kbd>ctrl+A</kbd> -> <kbd>K</kbd> -> <kbd>Y</kbd></br>
when **docker**,use:
```
make monitor
```
(pay attenrion, RTS and DTR are locked, so push reset button will not functional, use <kbd>ctrl+T</kbd>-><kbd>ctrl+H</kbd> to see help)
when **windows**,use serial monitor with GUI,such as **UartAssist.exe**

# directories description
```
src           source code
|---driver    driver source code
|---include   include files
|---user      user main
```
you can copy example from `example`to `src`,or delete `example` to make project clean~~


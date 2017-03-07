```
make           : compile project"
make flash     : compile and upload code to flash of board"
make erase     : erase all data in flash"
make monitor   : serial monitor tool"
make clean     : clean binary files"
make distclean : clean binary files and folders"
make help      : help info"
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


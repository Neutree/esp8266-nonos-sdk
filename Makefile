#  copyright (c) 2010 Espressif System
#  optimized by neucrack, refer to vowstar's modification

#parameter eg:
# ESPPORT = /dev/ttyUSB0
# DOWNLOADBAUD=1500000
# BOOT = new
# APP = 1
# SPI_SPEED = 40
# SPI_MODE = DIO
# SPI_SIZE_MAP = 2
# OS = Windows_NT
# COMPILE = gcc
# 
ifndef PDIR

endif

ifneq ($(wildcard bin/.*),)
	FW_PATH		?= bin
	ESPTOOL		?= python tools/esptool.py
else
	FW_PATH		?= ../bin
	ESPTOOL		?= python ../tools/esptool.py
endif

DOWNLOADBAUD ?= 1500000
BOOT?=new
APP?=1
SPI_SPEED?=40
SPI_MODE?=dio
SPI_SIZE_MAP?=2
COMPILE?=gcc
SPI_MODE := $(shell echo $(SPI_MODE) | tr '[A-Z]' '[a-z]')


# esptool path and port
ifeq ($(OS),Windows_NT)
	ESPTOOL		?= esptool.exe
	ifeq ($(TERM),cygwin)
		ESPPORT		?= /dev/ttyS2
	else
		ESPPORT		?= COM3
	endif
else
	ESPTOOL		?= esptool
	UNAME_S		:= $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		ESPPORT		?= /dev/cu.SLAB_USBtoUART
	endif
	ifeq ($(UNAME_S),Linux)
		ESPPORT		?= /dev/ttyUSB0
	endif
endif

ifeq ($(XTENSA_CORE),lx106)
	# It is xcc
	AR = xt-ar
	CC = xt-xcc
	NM = xt-nm
	CPP = xt-cpp
	OBJCOPY = xt-objcopy
	OBJDUMP = xt-objdump
else 
	ifeq ($(COMPILE), gcc)
		AR = xtensa-lx106-elf-ar
		CC = xtensa-lx106-elf-gcc
		NM = xtensa-lx106-elf-nm
		CPP = xtensa-lx106-elf-cpp
		OBJCOPY = xtensa-lx106-elf-objcopy
		OBJDUMP = xtensa-lx106-elf-objdump
	else
		AR = xt-ar
		CC = xt-xcc
		NM = xt-nm
		CPP = xt-cpp
		OBJCOPY = xt-objcopy
		OBJDUMP = xt-objdump
	endif
endif



ifeq ($(BOOT), new)
    boot = new
else
    ifeq ($(BOOT), old)
        boot = old
    else
        boot = none
    endif
endif

ifeq ($(APP), 1)
    app = 1
else
    ifeq ($(APP), 2)
        app = 2
    else
        app = 0
    endif
endif

ifeq ($(SPI_SPEED), 26.7)
    freqdiv = 1
else
    ifeq ($(SPI_SPEED), 20)
        freqdiv = 2
    else
        ifeq ($(SPI_SPEED), 80)
            freqdiv = 15
        else
            freqdiv = 0
        endif
    endif
endif


ifeq ($(SPI_MODE), qout)
    mode = 1
else
    ifeq ($(SPI_MODE), dio)
        mode = 2
    else
        ifeq ($(SPI_MODE), dout)
            mode = 3
        else
            mode = 0
        endif
    endif
endif

addr = 0x01000

ifeq ($(SPI_SIZE_MAP), 1)
  size_map = 1
  flash = 256
else
  ifeq ($(SPI_SIZE_MAP), 2)
    size_map = 2
    flash = 1024
    ifeq ($(app), 2)
      addr = 0x81000
    endif
  else
    ifeq ($(SPI_SIZE_MAP), 3)
      size_map = 3
      flash = 2048
      ifeq ($(app), 2)
        addr = 0x81000
      endif
    else
      ifeq ($(SPI_SIZE_MAP), 4)
        size_map = 4
        flash = 4096
        ifeq ($(app), 2)
          addr = 0x81000
        endif
      else
        ifeq ($(SPI_SIZE_MAP), 5)
          size_map = 5
          flash = 2048
          ifeq ($(app), 2)
            addr = 0x101000
          endif
        else
          ifeq ($(SPI_SIZE_MAP), 6)
            size_map = 6
            flash = 4096
            ifeq ($(app), 2)
              addr = 0x101000
            endif
          else
            size_map = 0
            flash = 512
            ifeq ($(app), 2)
              addr = 0x41000
            endif
          endif
        endif
      endif
    endif
  endif
endif

LD_FILE = $(LDDIR)/eagle.app.v6.ld

ifneq ($(boot), none)
ifneq ($(app),0)
    ifeq ($(size_map), 6)
      LD_FILE = $(LDDIR)/eagle.app.v6.$(boot).2048.ld
    else
      ifeq ($(size_map), 5)
        LD_FILE = $(LDDIR)/eagle.app.v6.$(boot).2048.ld
      else
        ifeq ($(size_map), 4)
          LD_FILE = $(LDDIR)/eagle.app.v6.$(boot).1024.app$(app).ld
        else
          ifeq ($(size_map), 3)
            LD_FILE = $(LDDIR)/eagle.app.v6.$(boot).1024.app$(app).ld
          else
            ifeq ($(size_map), 2)
              LD_FILE = $(LDDIR)/eagle.app.v6.$(boot).1024.app$(app).ld
            else
              ifeq ($(size_map), 0)
                LD_FILE = $(LDDIR)/eagle.app.v6.$(boot).512.app$(app).ld
              endif
            endif
	      endif
	    endif
	  endif
	endif
	BIN_NAME = user$(app).$(flash).$(boot).$(size_map)
endif
else
    app = 0
endif

CSRCS ?= $(wildcard *.c)
ASRCs ?= $(wildcard *.s)
ASRCS ?= $(wildcard *.S)
SUBDIRS ?= $(patsubst %/,%,$(dir $(wildcard */Makefile)))

ODIR := .output
OBJODIR := $(ODIR)/$(TARGET)/$(FLAVOR)/obj

OBJS := $(CSRCS:%.c=$(OBJODIR)/%.o) \
        $(ASRCs:%.s=$(OBJODIR)/%.o) \
        $(ASRCS:%.S=$(OBJODIR)/%.o)

DEPS := $(CSRCS:%.c=$(OBJODIR)/%.d) \
        $(ASRCs:%.s=$(OBJODIR)/%.d) \
        $(ASRCS:%.S=$(OBJODIR)/%.d)

LIBODIR := $(ODIR)/$(TARGET)/$(FLAVOR)/lib
OLIBS := $(GEN_LIBS:%=$(LIBODIR)/%)

IMAGEODIR := $(ODIR)/$(TARGET)/$(FLAVOR)/image
OIMAGES := $(GEN_IMAGES:%=$(IMAGEODIR)/%)

BINODIR := $(ODIR)/$(TARGET)/$(FLAVOR)/bin
OBINS := $(GEN_BINS:%=$(BINODIR)/%)

CCFLAGS += 			\
	-g			\
	-Wpointer-arith		\
	-Wundef			\
	-Werror			\
	-Wl,-EL			\
	-fno-inline-functions	\
	-nostdlib       \
	-mlongcalls	\
	-mtext-section-literals \
	-ffunction-sections \
	-fdata-sections	\
	-fno-builtin-printf
#	-Wall			

CFLAGS = $(CCFLAGS) $(DEFINES) $(EXTRA_CCFLAGS) $(INCLUDES)
DFLAGS = $(CCFLAGS) $(DDEFINES) $(EXTRA_CCFLAGS) $(INCLUDES)


#############################################################
# Functions
#

define ShortcutRule
$(1): .subdirs $(2)/$(1)
endef

define MakeLibrary
DEP_LIBS_$(1) = $$(foreach lib,$$(filter %.a,$$(COMPONENTS_$(1))),$$(dir $$(lib))$$(LIBODIR)/$$(notdir $$(lib)))
DEP_OBJS_$(1) = $$(foreach obj,$$(filter %.o,$$(COMPONENTS_$(1))),$$(dir $$(obj))$$(OBJODIR)/$$(notdir $$(obj)))
$$(LIBODIR)/$(1).a: $$(OBJS) $$(DEP_OBJS_$(1)) $$(DEP_LIBS_$(1)) $$(DEPENDS_$(1))
	@mkdir -p $$(LIBODIR)
	$$(if $$(filter %.a,$$?),mkdir -p $$(EXTRACT_DIR)_$(1))
	$$(if $$(filter %.a,$$?),cd $$(EXTRACT_DIR)_$(1); $$(foreach lib,$$(filter %.a,$$?),$$(AR) xo $$(UP_EXTRACT_DIR)/$$(lib);))
	$$(AR) ru $$@ $$(filter %.o,$$?) $$(if $$(filter %.a,$$?),$$(EXTRACT_DIR)_$(1)/*.o)
	$$(if $$(filter %.a,$$?),$$(RM) -r $$(EXTRACT_DIR)_$(1))
endef

define MakeImage
DEP_LIBS_$(1) = $$(foreach lib,$$(filter %.a,$$(COMPONENTS_$(1))),$$(dir $$(lib))$$(LIBODIR)/$$(notdir $$(lib)))
DEP_OBJS_$(1) = $$(foreach obj,$$(filter %.o,$$(COMPONENTS_$(1))),$$(dir $$(obj))$$(OBJODIR)/$$(notdir $$(obj)))
$$(IMAGEODIR)/$(1).out: $$(OBJS) $$(DEP_OBJS_$(1)) $$(DEP_LIBS_$(1)) $$(DEPENDS_$(1))
	@mkdir -p $$(IMAGEODIR)
	$$(CC) $$(LDFLAGS) $$(if $$(LINKFLAGS_$(1)),$$(LINKFLAGS_$(1)),$$(LINKFLAGS_DEFAULT) $$(OBJS) $$(DEP_OBJS_$(1)) $$(DEP_LIBS_$(1))) -o $$@ 
endef

$(BINODIR)/%.bin: $(IMAGEODIR)/%.out
	@mkdir -p $(BINODIR)
	
ifeq ($(APP), 0)
	@$(RM) -r ../bin/eagle.S ../bin/eagle.dump
	@$(OBJDUMP) -x -s $< > ../bin/eagle.dump
	@$(OBJDUMP) -S $< > ../bin/eagle.S
else
	mkdir -p ../bin/upgrade
	@$(RM) -r ../bin/upgrade/$(BIN_NAME).S ../bin/upgrade/$(BIN_NAME).dump
	@$(OBJDUMP) -x -s $< > ../bin/upgrade/$(BIN_NAME).dump
	@$(OBJDUMP) -S $< > ../bin/upgrade/$(BIN_NAME).S
endif

	@$(OBJCOPY) --only-section .text -O binary $< eagle.app.v6.text.bin
	@$(OBJCOPY) --only-section .data -O binary $< eagle.app.v6.data.bin
	@$(OBJCOPY) --only-section .rodata -O binary $< eagle.app.v6.rodata.bin
	@$(OBJCOPY) --only-section .irom0.text -O binary $< eagle.app.v6.irom0text.bin

	@echo ""
	@echo "!!!"
	
ifeq ($(app), 0)
	@python ../tools/gen_appbin.py $< 0 $(mode) $(freqdiv) $(size_map) $(app)
	@mv eagle.app.flash.bin ../bin/eagle.flash.bin
	@mv eagle.app.v6.irom0text.bin ../bin/eagle.irom0text.bin
	@rm eagle.app.v6.*
	@echo "No boot needed."
	@echo "Generate eagle.flash.bin and eagle.irom0text.bin successully in folder bin."
	@echo "eagle.flash.bin-------->0x00000"
	@echo "eagle.irom0text.bin---->0x10000"
else
    ifneq ($(boot), new)
		@python ../tools/gen_appbin.py $< 1 $(mode) $(freqdiv) $(size_map) $(app)
		@echo "Support boot_v1.1 and +"
    else
		@python ../tools/gen_appbin.py $< 2 $(mode) $(freqdiv) $(size_map) $(app)

    	ifeq ($(size_map), 6)
		@echo "Support boot_v1.4 and +"
        else
            ifeq ($(size_map), 5)
		@echo "Support boot_v1.4 and +"
            else
		@echo "Support boot_v1.2 and +"
            endif
        endif
    endif

	@mv eagle.app.flash.bin ../bin/upgrade/$(BIN_NAME).bin
	@rm eagle.app.v6.*
	@echo "Generate $(BIN_NAME).bin successully in folder bin/upgrade."
	@echo "boot.bin------------>0x00000"
	@echo "$(BIN_NAME).bin--->$(addr)"
endif

	@echo "!!!"

#############################################################
# Rules base
# Should be done in top-level makefile only
#

all:	.subdirs $(OBJS) $(OLIBS) $(OIMAGES) $(OBINS) $(SPECIAL_MKTARGETS)

flash: all
	@echo "Programming ..."
	@$(ESPTOOL) --port $(ESPPORT) --baud $(DOWNLOADBAUD) write_flash --flash_mode $(SPI_MODE) --flash_size 8m \
	0x00000 $(FW_PATH)/boot_v1.6.bin \
	0x01000 $(FW_PATH)/upgrade/user1.1024.new.2.bin \
	0xFC000 $(FW_PATH)/esp_init_data_default.bin \
	0x7e000 $(FW_PATH)/blank.bin \
	0xFE000 $(FW_PATH)/blank.bin	
	@echo "Please set baudrate and other configuration, e.g."
	@echo "stty -F $(ESPPORT) speed 115200 cs8 -cstopb"
	@echo "Now you can watch debug output"
	@echo "cat $(ESPPORT)"
	@echo "Using [CTRL+C] to stop it"
	@echo "Firmware Map"
	@echo "boot_v1.6.bin---------------->\033[0;33m0x00000\033[0m"
	@echo "user1.4096.new.4.bin--------->\033[0;33m0x01000\033[0m"
	@echo "user2.4096.new.4.bin--------->\033[0;33m0x81000\033[0m"
	@echo "blank.bin-------------------->\033[0;33m0x7E000\033[0m"
	@echo "\033[92m[Finish]\033[0m"

#       -$(ESPTOOL) -cd nodemcu -cb 921600 -cp $(ESPPORT)                       \
#       -ca 0x00000 -cf $(FW_PATH)/boot_v1.6_vowstar.bin                        \
#       -ca 0x01000 -cf $(FW_PATH)/upgrade/user1.1024.new.2.bin         \
#       -ca 0xFC000 -cf $(FW_PATH)/esp_init_data_default.bin            \
#       -ca 0x7e000 -cf $(FW_PATH)/blank.bin                                            \
#       -ca 0xFE000 -cf $(FW_PATH)/blank.bin 

wificlean:
	@echo "Cleaning wifi ..."
	@$(ESPTOOL) --port $(ESPPORT) --baud $(DOWNLOADBAUD) write_flash --flash_mode $(SPI_MODE) --flash_size 8m \
	0xFC000 $(FW_PATH)/esp_init_data_default.bin \
	0x7e000 $(FW_PATH)/blank.bin \
	0xFE000 $(FW_PATH)/blank.bin	
#	-$(ESPTOOL) -cd nodemcu -cb 921600 -cp $(ESPPORT) 			\
#	-ca 0xFC000 -cf $(FW_PATH)/esp_init_data_default.bin        \
#	-ca 0x7e000 -cf $(FW_PATH)/blank.bin 						\
#	-ca 0xFE000 -cf $(FW_PATH)/blank.bin 			

dataclean:
	@echo "Cleaning data ..." 
	@$(ESPTOOL) --port $(ESPPORT) --baud $(DOWNLOADBAUD) write_flash --flash_mode $(SPI_MODE) --flash_size 8m \
	0xF4000 $(FW_PATH)/blank.bin \
	0xF5000 $(FW_PATH)/blank.bin \
	0xF6000 $(FW_PATH)/blank.bin
#	-$(ESPTOOL) -cd nodemcu -cb 921600 -cp $(ESPPORT) 			\
#	-ca 0xF4000 -cf $(FW_PATH)/blank.bin 						\
#	-ca 0xF5000 -cf $(FW_PATH)/blank.bin 						\
#	-ca 0xF6000 -cf $(FW_PATH)/blank.bin

erase:
	@echo "Erasing flash ..."
	@$(ESPTOOL) --port $(ESPPORT) --baud $(DOWNLOADBAUD) erase_flash
#	-$(ESPTOOL) -cd nodemcu -cb 921600 -cp $(ESPPORT) -ce

monitor:
	python -m serial.tools.miniterm --rts 0 --dtr 0 --raw $(ESPPORT) 115200

help:
	@echo "make           : compile project"
	@echo "make flash     : compile and upload code to flash of board"
	@echo "make erase     : erase all data in flash"
	@echo "make monitor   : serial monitor tool"
	@echo "make clean     : clean binary files"
	@echo "make distclean : clean binary files and folders"
	@echo "make help      : help info"
	@echo "parameters: (parameter = value)"
	@echo "ESPPORT      = "$(ESPPORT)
	@echo "DOWNLOADBAUD = "$(DOWNLOADBAUD)
	@echo "BOOT         = "$(BOOT)
	@echo "APP          = "$(APP)
	@echo "SPI_SPEED    = "$(SPI_SPEED)
	@echo "SPI_MODE     = "$(SPI_MODE)
	@echo "SPI_SIZE_MAP = "$(SPI_SIZE_MAP)
	@echo "OS           = "$(OS)
	@echo "COMPILE      = "$(COMPILE)

clean:
	$(foreach d, $(SUBDIRS), $(MAKE) -C $(d) clean;)
	$(RM) -r $(ODIR)/$(TARGET)/$(FLAVOR)

distclean:
	$(foreach d, $(SUBDIRS), $(MAKE) -C $(d) distclean;)
	$(RM) -r $(ODIR)

clobber: $(SPECIAL_CLOBBER)
	$(foreach d, $(SUBDIRS), $(MAKE) -C $(d) clobber;)
	$(RM) -r $(ODIR)

.subdirs:
	@set -e; $(foreach d, $(SUBDIRS), $(MAKE) -C $(d);)

#.subdirs:
#	$(foreach d, $(SUBDIRS), $(MAKE) -C $(d))

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),clobber)
ifdef DEPS
sinclude $(DEPS)
endif
endif
endif

$(OBJODIR)/%.o: %.c
	@mkdir -p $(OBJODIR);
	$(CC) $(if $(findstring $<,$(DSRCS)),$(DFLAGS),$(CFLAGS)) $(COPTS_$(*F)) -o $@ -c $<

$(OBJODIR)/%.d: %.c
	@mkdir -p $(OBJODIR);
	@echo DEPEND: $(CC) -M $(CFLAGS) $<
	@set -e; rm -f $@; \
	$(CC) -M $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\.o\)[ :]*,$(OBJODIR)/\1 $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(OBJODIR)/%.o: %.s
	@mkdir -p $(OBJODIR);
	$(CC) $(CFLAGS) -o $@ -c $<

$(OBJODIR)/%.d: %.s
	@mkdir -p $(OBJODIR); \
	set -e; rm -f $@; \
	$(CC) -M $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\.o\)[ :]*,$(OBJODIR)/\1 $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(OBJODIR)/%.o: %.S
	@mkdir -p $(OBJODIR);
	$(CC) $(CFLAGS) -D__ASSEMBLER__ -o $@ -c $<

$(OBJODIR)/%.d: %.S
	@mkdir -p $(OBJODIR); \
	set -e; rm -f $@; \
	$(CC) -M $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\.o\)[ :]*,$(OBJODIR)/\1 $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(foreach lib,$(GEN_LIBS),$(eval $(call ShortcutRule,$(lib),$(LIBODIR))))

$(foreach image,$(GEN_IMAGES),$(eval $(call ShortcutRule,$(image),$(IMAGEODIR))))

$(foreach bin,$(GEN_BINS),$(eval $(call ShortcutRule,$(bin),$(BINODIR))))

$(foreach lib,$(GEN_LIBS),$(eval $(call MakeLibrary,$(basename $(lib)))))

$(foreach image,$(GEN_IMAGES),$(eval $(call MakeImage,$(basename $(image)))))

#############################################################
# Recursion Magic - Don't touch this!!
#
# Each subtree potentially has an include directory
#   corresponding to the common APIs applicable to modules
#   rooted at that subtree. Accordingly, the INCLUDE PATH
#   of a module can only contain the include directories up
#   its parent path, and not its siblings
#
# Required for each makefile to inherit from the parent
#

INCLUDES := $(INCLUDES) -I $(PDIR)include -I $(PDIR)include/$(TARGET)
PDIR := ../$(PDIR)
sinclude $(PDIR)Makefile

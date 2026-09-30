#---------------------------------------------------------------------------------
# Makefile for th06-switch (Touhou 6 EoSD portable -> Nintendo Switch)
#---------------------------------------------------------------------------------
.SUFFIXES:

ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>/devkitpro")
endif

TOPDIR ?= $(CURDIR)
include $(DEVKITPRO)/libnx/switch_rules

TARGET      := touhou6
BUILD       := build
SOURCES     := src src/graphics src/pbg3 src/thirdparty src/midi platform/switch
DATA        := data
INCLUDES    := src src/graphics src/pbg3 src/thirdparty src/midi platform/switch
ROMFS       := romfs
APP_TITLE   := Touhou 6: the Embodiment of Scarlet Devil
APP_AUTHOR  := ZUN / Team Shanghai Alice
APP_VERSION := 1.02h
ICON        := icon.jpg

ARCH        := -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE

CFLAGS      := -g -Wall -O2 -ffunction-sections \
               $(ARCH) $(DEFINES)

CFLAGS      += $(INCLUDE) -D__SWITCH__ -DUSE_C23_EMBED \
               -DGAME_WINDOW_WIDTH_REAL=1280 -DGAME_WINDOW_HEIGHT_REAL=720

CXXFLAGS    := $(CFLAGS) -std=gnu++20 -fno-rtti \
               -Wno-narrowing -Wno-unused-parameter \
               -Wno-unused-variable -Wno-missing-field-initializers

ASFLAGS     := -g $(ARCH)
LDFLAGS      = -specs=$(DEVKITPRO)/libnx/switch.specs -g $(ARCH) -Wl,-Map,$(notdir $*.map)

LIBS        := -lSDL2_ttf -lSDL2_image -lSDL2 \
               -lpng -ljpeg -lfreetype -lharfbuzz -lfreetype \
               -lwebp -lwebpdemux -lavif \
               -lEGL -lglapi -ldrm_nouveau -lGLESv2 \
               -lz -lbz2 \
               -lnx -lm

LIBDIRS     := $(PORTLIBS) $(LIBNX)

ifneq ($(BUILD),$(notdir $(CURDIR)))

export OUTPUT   := $(CURDIR)/$(TARGET)
export TOPDIR   := $(CURDIR)

export VPATH    := $(foreach dir,$(SOURCES),$(CURDIR)/$(dir)) \
                   $(foreach dir,$(DATA),$(CURDIR)/$(dir))

export DEPSDIR  := $(CURDIR)/$(BUILD)

CFILES          := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES        := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
SFILES          := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
BINFILES        := $(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))

EXCLUDED        := MidiAlsa.cpp MidiCoreAudio.cpp MidiWin32.cpp MidiDefault.cpp
CPPFILES        := $(filter-out $(EXCLUDED),$(CPPFILES))

ifeq ($(strip $(CPPFILES)),)
export LD       := $(CC)
else
export LD       := $(CXX)
endif

export OFILES_BIN    := $(addsuffix .o,$(BINFILES))
export OFILES_SRC    := $(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)
export OFILES        := $(OFILES_BIN) $(OFILES_SRC)
export HFILES_BIN    := $(addsuffix .h,$(subst .,_,$(BINFILES)))

export INCLUDE  := $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
                   $(foreach dir,$(LIBDIRS),-I$(dir)/include) \
                   -I$(CURDIR)/$(BUILD) \
                   `sdl2-config --cflags` 2>/dev/null

export LIBPATHS := $(foreach dir,$(LIBDIRS),-L$(dir)/lib)

export BUILD_ROMFS := $(TOPDIR)/$(ROMFS)

ifeq ($(strip $(ICON)),)
    icons := $(wildcard *.jpg)
    ifneq (,$(findstring $(TARGET).jpg,$(icons)))
        export APP_ICON := $(TOPDIR)/$(TARGET).jpg
    else ifneq (,$(findstring icon.jpg,$(icons)))
        export APP_ICON := $(TOPDIR)/icon.jpg
    endif
else
    export APP_ICON := $(TOPDIR)/$(ICON)
endif

ifeq ($(strip $(NO_ICON)),)
    export NROFLAGS += --icon=$(APP_ICON)
endif

ifeq ($(strip $(NO_NACP)),)
    export NROFLAGS += --nacp=$(CURDIR)/$(TARGET).nacp
endif

ifneq ($(ROMFS),)
    export NROFLAGS += --romfsdir=$(CURDIR)/$(ROMFS)
endif

.PHONY: $(BUILD) clean all

all: $(BUILD)

$(BUILD):
	@[ -d $@ ] || mkdir -p $@
	@[ -d $(ROMFS) ] || mkdir -p $(ROMFS)
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

clean:
	@echo clean ...
	@rm -fr $(BUILD) $(TARGET).nro $(TARGET).nacp $(TARGET).elf

else
DEPENDS := $(OFILES:.o=.d)

all     : $(OUTPUT).nro

$(OUTPUT).nro   :   $(OUTPUT).elf $(OUTPUT).nacp
$(OUTPUT).elf   :   $(OFILES)

# hbmenu title: romanised in every language slot, the original Japanese
# title in the Japanese slot only (same as th07/th08/th10-switch).
$(OUTPUT).nacp  :   $(MAKEFILE_LIST) $(TOPDIR)/scripts/nacp_lang.py
	@nacptool --create "$(APP_TITLE)" "$(APP_AUTHOR)" "$(APP_VERSION)" $@.base $(NACPFLAGS)
	@python3 $(TOPDIR)/scripts/nacp_lang.py $@.base $@ --lang Japanese \
		--name "東方紅魔郷　～ the Embodiment of Scarlet Devil" --author "上海アリス幻樂団" \
		--fill-empty-name "$(APP_TITLE)" --fill-empty-author "$(APP_AUTHOR)"
	@rm -f $@.base
	@echo built ... $(notdir $@)

$(OFILES_SRC)   :   $(HFILES_BIN)

%.bin.o %_bin.h  :   %.bin
	@echo $(notdir $<)
	@$(bin2o)

-include $(DEPENDS)
endif

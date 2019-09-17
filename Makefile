
SMSDK = ./sourcemod

PROJECT = hackfortress

EXTENSION_SOURCE = smsdk_config.h smsdk_ext.cpp extension.cpp
EXTENSION_OUT = build/extension/

C_OPT_FLAGS = -DNDEBUG -O3 -funroll-loops -pipe -fno-strict-aliasing
C_DEBUG_FLAGS = -D_DEBUG -DDEBUG -g -ggdb3
CPP = gcc
LIB_EXT = so

INCLUDE += -I. -I$(SMSDK)/public -I$(SMSDK)/sourcepawn/include -I$(SMSDK)/public/amtl -I$(SMSDK)/public/amtl/amtl 

LINK += -m32 -lm -ldl -shared -static-libgcc

CFLAGS += -DPOSIX -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp -Dstrnicmp=strncasecmp \
	-D_snprintf=snprintf -D_vsnprintf=vsnprintf -D_alloca=alloca -Dstrcmpi=strcasecmp -DCOMPILER_GCC -Wall -Werror \
	-Wno-overloaded-virtual -Wno-switch -Wno-unused -msse -DSOURCEMOD_BUILD -DHAVE_STDINT_H -m32 -D_LINUX
CPPFLAGS += -Wno-non-virtual-dtor -fno-exceptions -fno-rtti -std=c++11

#### 

BINARY = $(PROJECT).ext.$(LIB_EXT)

ifeq "$(DEBUG)" "true"
	CFLAGS += $(C_DEBUG_FLAGS)
else
	CFLAGS += $(C_OPT_FLAGS)
endif

OBJ_BIN := $(EXTENSION_SOURCE:%.cpp=$(EXTENSION_OUT)/%.o)

$(EXTENSION_OUT)/%.o: %.cpp
	$(CPP) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

all:
	mkdir -p $(EXTENSION_OUT)

extension: $(OBJ_BIN)
	$(CPP) $(INCLUDE) $(OBJ_BIN) $(LINK) -o $(EXTENSION_OUT)/$(BINARY)

default: all

clean:
	rm -rf $(EXTENSION_OUT)/*.o
	rm -rf $(EXTENSION_OUT)/$(BINARY)
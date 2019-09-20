
SMSDK = ./sourcemod

PROJECT = hackfortress

EXTENSION_SOURCE = smsdk_config.h smsdk_ext.cpp extension.cpp
GRPC_SOURCE = exchanger.grpc.pb.cc exchanger.grpc.pb.h exchanger.pb.cc exchanger.pb.h
EXTENSION_OUT = build/extension/

EXTENSION_SOURCE += $(GRPC_SOURCE)

PROTO_PATH = proto/
PROTOC = protoc
GRPC_CPP_PLUGIN := grpc_cpp_plugin
GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

C_OPT_FLAGS = -DNDEBUG -O3 -funroll-loops -pipe -fno-strict-aliasing
C_DEBUG_FLAGS = -D_DEBUG -DDEBUG -g -ggdb3
CPP = g++
LIB_EXT = so

INCLUDE += -I. -I$(SMSDK)/public -I$(SMSDK)/sourcepawn/include -I$(SMSDK)/public/amtl -I$(SMSDK)/public/amtl/amtl 

LDFLAGS += -L/usr/include -L/usr/lib `pkg-config --libs protobuf grpc++` \
		   -m32 -lm -ldl -shared -static-libgcc \
		   -pthread \
		   -Wl,--no-as-needed -lgrpc++_reflection \
		   -Wl,--as-needed

CFLAGS += -DPOSIX -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp -Dstrnicmp=strncasecmp \
	-D_snprintf=snprintf -D_vsnprintf=vsnprintf -D_alloca=alloca -Dstrcmpi=strcasecmp -DCOMPILER_GCC -Wall -Werror \
	-Wno-overloaded-virtual -Wno-switch -Wno-unused -msse -DSOURCEMOD_BUILD -DHAVE_STDINT_H -m32 -D_LINUX
CPPFLAGS += -Wno-non-virtual-dtor -fno-exceptions -fno-rtti -std=c++11 `pkg-config --cflags protobuf grpc`

#### 

BINARY = $(PROJECT).ext.$(LIB_EXT)

vpath %.proto $(PROTO_PATH)

ifeq "$(DEBUG)" "true"
	CFLAGS += $(C_DEBUG_FLAGS)
else
	CFLAGS += $(C_OPT_FLAGS)
endif

OBJ_BIN := $(EXTENSION_SOURCE:%.cpp=$(EXTENSION_OUT)/%.o)

%.grpc.pb.cc: %.proto
	$(PROTOC) -I $(PROTO_PATH) --grpc_out=./ \
		--plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) \
		$<

%.pb.cc: %.proto
	$(PROTOC) -I $(PROTO_PATH) --cpp_out=./ $<

$(EXTENSION_OUT)/%.o: %.cpp %.grpc.pb.cc %.pb.cc
	$(CPP) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

all:
	mkdir -p $(EXTENSION_OUT)

gen-cpp:  $(GRPC_SOURCE)
	@echo "Generated gRCP code"

extension: $(OBJ_BIN)
	$(CPP) $(INCLUDE) $(OBJ_BIN) $(LDFLAGS) -o $(EXTENSION_OUT)/$(BINARY)

default: all

clean:
	rm -rf $(EXTENSION_OUT)/*.o
	rm -rf $(EXTENSION_OUT)/$(BINARY)

# name of your application
APPLICATION = ocaml

# If no BOARD is found in the environment, use this default:
# BOARD ?= nrf52840-mdk
BOARD ?= native 

# This has to be the absolute path to the RIOT base directory:
RIOTBASE ?= $(CURDIR)/RIOT

# Comment this out to disable code in RIOT that does safety checking
# which is not needed in a production environment but helps in the
# development process:
DEVELHELP ?= 1

# Change this to 0 show compiler invocation lines by default:
QUIET ?= 0

# Our own modules that perform event handling

USEMODULE += xtimer event stdin event_callback
FEATURES_REQUIRED += periph_uart

# Include network device module and auto init
USEMODULE += netdev_default
USEMODULE += auto_init_gnrc_netif
# # Include RIOT gnrc network layer
USEMODULE += gnrc_ipv6_default
USEMODULE += gnrc_icmpv6_echo
# # Add a routing protocol
# USEMODULE += gnrc_rpl
# USEMODULE += auto_init_gnrc_rpl
USEMODULE += gnrc_sock_ip
USEMODULE += gnrc_pktdump

USEMODULE += shell
USEMODULE += shell_commands
USEMODULE += ps

USEMODULE += raw_tcp_sock
USEMODULE += ocaml_event_sig
USEMODULE += ocaml_runtime
USEMODULE += stubs
EXTERNAL_MODULE_DIRS += external_modules

all: runtime.c stubs runtimelib

include $(RIOTBASE)/Makefile.include

stubs: example/stubs.c
	cp $(^) ./external_modules/stubs/stubs.c

runtime.c: example/* 
	cd example && dune build --profile release
	rm -f ./external_modules/ocaml_runtime/runtime.c
	cp _build/default/example/main.bc.c ./external_modules/ocaml_runtime/runtime.c

ocaml/Makefile:
	sed -i -e 's/oc_cflags="/oc_cflags="$$OC_CFLAGS /g' ocaml/configure
	sed -i -e 's/ocamlc_cflags="/ocamlc_cflags="$$OCAMLC_CFLAGS /g' ocaml/configure

CFLAGS := $(subst \",",$(CFLAGS))
CFLAGS := $(subst ',,$(CFLAGS))
CFLAGS := $(subst -Wstrict-prototypes,,$(CFLAGS))
CFLAGS := $(subst -Werror,,$(CFLAGS))
CFLAGS := $(subst -Wold-style-definition,,$(CFLAGS))

OCAML_CFLAGS := $(CFLAGS)
OCAML_LIBS := $(LINKFLAGS)
# RIOTBUILD_H_FILE := $(CURDIR)/bin/nrf52840-mdk/riotbuild/riotbuild.h
RIOTBUILD_H_FILE := $(CURDIR)/bin/native/riotbuild/riotbuild.h
.PHONY: runtimelib
runtimelib: $(RIOTBUILD_H_FILE)
	CC="$(CC)" \
	CFLAGS="" \
	AS="$(AS)" \
	ASPP="$(CC) $(OCAML_CFLAGS) -c" \
	CPPFLAGS="$(OCAML_CFLAGS)" \
	LIBS="$(OCAML_LIBS) --entry main" \
	dune build include/ ./external_modules/ocaml_runtime/libcamlrun.a --verbose

CFLAGS += -I$(CURDIR)/include/
CFLAGS += -mrdrnd -mrdseed #for x86
LINKFLAGS += -L$(CURDIR) -L$(CURDIR)/external_modules/ocaml_runtime -lcamlrun -lm

print :
	echo $(BASELIBS)
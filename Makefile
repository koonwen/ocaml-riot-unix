# name of your application
APPLICATION = ocaml

# If no BOARD is found in the environment, use this default:
BOARD ?= nrf52840-mdk
# BOARD ?= native 

# This has to be the absolute path to the RIOT base directory:
RIOTBASE ?= $(CURDIR)/../Repos/RIOT

# Comment this out to disable code in RIOT that does safety checking
# which is not needed in a production environment but helps in the
# development process:
DEVELHELP ?= 1

# Change this to 0 show compiler invocation lines by default:
QUIET ?= 0

# Our own modules that perform event handling

USEMODULE += xtimer stdin
# FEATURES_REQUIRED += periph_uart

# # Include network device module and auto init
# USEMODULE += netdev_default
# USEMODULE += auto_init_gnrc_netif
# # # Include RIOT gnrc network layer
# USEMODULE += gnrc_ipv6_default
# USEMODULE += gnrc_icmpv6_echo
# # # Add a routing protocol
# # USEMODULE += gnrc_rpl
# # USEMODULE += auto_init_gnrc_rpl
# USEMODULE += gnrc_sock_ip

# USEMODULE += shared
# USEMODULE += raw_tcp_sock
# USEMODULE += ocaml_runtime
USEMODULE += sbs
EXTERNAL_MODULE_DIRS += external_modules

all: runtime.c runtimelib

include $(RIOTBASE)/Makefile.include

# stubs: example/stubs.c
# 	cp $(^) ./external_modules/stubs/stubs.c

runtime.c: example/* 
	cd example && dune build --profile release
	rm -f runtime.c
	cp _build/default/example/main.bc.c runtime.c
	chmod +w runtime.c
	dune exec -- ocamlclean runtime.c -o runtime.c

ocaml/Makefile:
	sed -i -e 's/oc_cflags="/oc_cflags="$$OC_CFLAGS /g' ocaml/configure
	sed -i -e 's/ocamlc_cflags="/ocamlc_cflags="$$OCAMLC_CFLAGS /g' ocaml/configure

CFLAGS := $(subst \",",$(CFLAGS))
CFLAGS := $(subst ',,$(CFLAGS))
CFLAGS := $(subst -Wstrict-prototypes,,$(CFLAGS))
CFLAGS := $(subst -Werror,,$(CFLAGS))
CFLAGS := $(subst -Wold-style-definition,,$(CFLAGS))
CFLAGS := $(subst -Wformat-overflow,,$(CFLAGS))
CFLAGS := $(subst -Wformat-truncation,,$(CFLAGS))
CFLAGS := $(subst -gz,,$(CFLAGS))

OCAML_CFLAGS := $(CFLAGS)
OCAML_LIBS := $(LINKFLAGS)
RIOTBUILD_H_FILE := $(CURDIR)/bin/nrf52840-mdk/riotbuild/riotbuild.h
.PHONY: runtimelib
runtimelib: $(RIOTBUILD_H_FILE)
	CC="$(CC)" \
	CFLAGS="" \
	AS="$(AS)" \
	ASPP="$(CC) $(OCAML_CFLAGS) -c" \
	CPPFLAGS="$(OCAML_CFLAGS)" \
	LIBS="$(OCAML_LIBS) --entry main" \
	dune build include/ libcamlrun.a --verbose

CFLAGS += -I$(CURDIR)/include/
LINKFLAGS += -L$(CURDIR) -lcamlrun -lm

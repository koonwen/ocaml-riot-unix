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

# LOG_NONE
#     Lowest log level, will output nothing. 
# LOG_ERROR
#     Error log level, will print only critical, non-recoverable errors like hardware initialization failures. 
# LOG_WARNING
#     Warning log level, will print warning messages for temporary errors. 
# LOG_INFO
#     Informational log level, will print purely informational messages like successful system bootup, network link state, … 
# LOG_DEBUG
#     Debug log level, printing developer stuff considered too verbose for production use. 
# LOG_ALL
LOG_LEVEL ?= LOG_NONE

# Change this to 0 show compiler invocation lines by default:
QUIET ?= 0

USEMODULE += xtimer event stdin event_callback
# FEATURES_REQUIRED += periph_uart
# USEMODULE += shell shell_commands ps netstats_l2 netstats_ipv6

# Include network device module and auto init
USEMODULE += netdev_default
USEMODULE += auto_init_gnrc_netif
# Include RIOT gnrc network layer
USEMODULE += gnrc_ipv6_default
USEMODULE += gnrc_icmpv6_echo
# Include sock API
USEMODULE += gnrc_sock_ip

# Our external modules for the translation layer
EXTERNAL_MODULE_DIRS += external_modules
USEMODULE += shared
USEMODULE += raw_tcp_sock
USEMODULE += ocaml_runtime
USEMODULE += ocaml_event_sig
USEMODULE += stubs

all: stubs runtimelib 
# runtime
# @if [ BOARD = "native" ]; then\
#     echo "native compilation";\
# else
# 	echo "nrf52840";\
# 	RIOTBUILD_H_FILE := $(CURDIR)/bin/nrf52840-mdk/riotbuild/riotbuild.h
# fi
# runtime

# Uncomment the following 2 lines to specify static link lokal IPv6 address
# this might be useful for testing, in cases where you cannot or do not want to
# run a shell with ifconfig to get the real link lokal address.
# IPV6_STATIC_LLADDR ?= '"fe80::cafe:cafe:cafe:1"'
# CFLAGS += -DGNRC_IPV6_STATIC_LLADDR=$(IPV6_STATIC_LLADDR)

include $(RIOTBASE)/Makefile.include

stubs: example/stubs.c
	cp $(^) ./external_modules/stubs/stubs.c

# build with dune and 
runtime: example/* 
	cd example && dune build --profile release
	rm -f ./external_modules/ocaml_runtime/runtime.c
	cp _build/default/example/main.bc.c ./external_modules/ocaml_runtime/runtime.c

optimize: external_modules/ocaml_runtime/runtime.c
	chmod +w ./external_modules/ocaml_runtime/runtime.c
	time dune exec -- ocamlclean ./external_modules/ocaml_runtime/runtime.c -o ./runtime.c
	mv ./runtime.c external_modules/ocaml_runtime/runtime.c
	sed -i 's/static int caml_code/const static int caml_code/g' ./external_modules/ocaml_runtime/runtime.c

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
RIOTBUILD_H_FILE := $(CURDIR)/bin/native/riotbuild/riotbuild.h
.PHONY: runtimelib
runtimelib: $(RIOTBUILD_H_FILE)
	CC="$(CC)" \
	CFLAGS="" \
	AS="$(AS)" \
	ASPP="$(CC) $(OCAML_CFLAGS) -c" \
	CPPFLAGS="$(OCAML_CFLAGS)" \
	LIBS="$(OCAML_LIBS) --entry main" \
	dune build include/ libcamlrun.a --verbose
	mv libcamlrun.a ./external_modules/ocaml_runtime

CFLAGS += -mrdrnd -mrdseed #for x86
CFLAGS += -I$(CURDIR)/include/
LINKFLAGS += -L$(CURDIR) -L$(CURDIR)/external_modules/ocaml_runtime -lcamlrun -lm

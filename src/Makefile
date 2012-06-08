
SYSTEM = $(shell uname)

export TD=$(abspath ..)

include $(TD)/Makefile.conf

SOURCES = nlopt_wrapper.c nlopt.ml nlopt.mli

TARGETS = ncl bcl top 
RESULT = nlopt

RESULTDIR = $(shell ocamlfind query $(RESULT))

all: 	$(TARGETS)

TRASH = 

uninstall:
	$(shell ocamlfind remove $(RESULT))

ifeq ('$(RESULTDIR)','')
install: libinstall	
else
install: uninstall libinstall
endif

include $(OCAMLMAKEFILE)











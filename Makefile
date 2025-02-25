MAKEFLAGS+=--no-print-directory
DEMISTIFYPATH=DeMiSTify
SUBMODULES=$(DEMISTIFYPATH)/EightThirtyTwo/lib832/lib832.a
PROJECT=c16
PROJECTPATH=./
PROJECTTOROOT=../
BOARD=
ROMSIZE1=8192
ROMSIZE2=4096

all: $(DEMISTIFYPATH)/site.mk $(SUBMODULES) firmware init compile tns mist

$(DEMISTIFYPATH)/site.mk:
	$(info ******************************************************)
	$(info Please copy the example DeMiSTify/site.template file to)
	$(info DeMiSTify/site.mk and edit the paths for the version(s))
	$(info of Quartus you have installed.)
	$(info *******************************************************)
	$(error site.mk not found.)

include $(DEMISTIFYPATH)/site.mk

$(DEMISTIFYPATH)/EightThirtyTwo/Makefile:
	git submodule update --init --recursive

$(SUBMODULES): $(DEMISTIFYPATH)/EightThirtyTwo/Makefile
	@make -C $(DEMISTIFYPATH) -f bootstrap.mk

.PHONY: firmware
firmware: $(SUBMODULES)
	@make -C firmware -f ../$(DEMISTIFYPATH)/Makefile DEMISTIFYPATH=../$(DEMISTIFYPATH) ROMSIZE1=$(ROMSIZE1) ROMSIZE2=$(ROMSIZE2) firmware

.PHONY: firmware_clean
firmware_clean: $(SUBMODULES)
	@make -C firmware -f ../$(DEMISTIFYPATH)/firmware/Makefile DEMISTIFYPATH=../$(DEMISTIFYPATH) ROMSIZE1=$(ROMSIZE1) ROMSIZE2=$(ROMSIZE2) clean

.PHONY: init
init:
	@make -f $(DEMISTIFYPATH)/Makefile DEMISTIFYPATH=$(DEMISTIFYPATH) PROJECTTOROOT=$(PROJECTTOROOT) PROJECTPATH=$(PROJECTPATH) PROJECTS=$(PROJECT) BOARD=$(BOARD) init 

.PHONY: compile
compile: 
	@make -f $(DEMISTIFYPATH)/Makefile DEMISTIFYPATH=$(DEMISTIFYPATH) PROJECTTOROOT=$(PROJECTTOROOT) PROJECTPATH=$(PROJECTPATH) PROJECTS=$(PROJECT) BOARD=$(BOARD) compile

.PHONY: clean
clean:
	@make -f $(DEMISTIFYPATH)/Makefile DEMISTIFYPATH=$(DEMISTIFYPATH) PROJECTTOROOT=$(PROJECTTOROOT) PROJECTPATH=$(PROJECTPATH) PROJECTS=$(PROJECT) BOARD=$(BOARD) clean

.PHONY: tns
tns:
	@for BOARD in ${BOARDS}; do \
		echo $$BOARD; \
		grep -r Design-wide\ TNS $$BOARD/*.rpt; \
	done

.PHONY: mist
mist:
	@echo -n "Compiling $(PROJECT) for mist... "
	@$(Q13)/quartus_sh >mist/compile.log --flow compile mist/$(PROJECT)_mist.qpf && echo "\033[32mSuccess\033[0m" || grep Error mist/compile.log


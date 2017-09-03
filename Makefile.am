###############################################################################
## Makefile for apertium-ita
###############################################################################

VERSION=0.10.0
LANG1=ita
BASENAME=apertium-$(LANG1)

TARGETS_COMMON = $(LANG1).automorf.bin $(LANG1).autogen.bin \
	$(LANG1).autopgen.bin \
	$(LANG1).automorf.att.gz $(LANG1).autogen.att.gz \
        $(LANG1).rlx.bin

# This include defines goals for install-modes, .deps/.d and .mode files:
@ap_include@

###############################################################################
## Transducer
###############################################################################

$(LANG1).autogen.bin: $(BASENAME).$(LANG1).dix
	apertium-validate-dictionary $<
	lt-comp rl $< $@

$(LANG1).automorf.bin: $(BASENAME).$(LANG1).dix $(BASENAME).$(LANG1).acx .deps/.d
	apertium-validate-dictionary $<
	apertium-validate-acx $(BASENAME).$(LANG1).acx
	@AWK@ -f ./inline_e.awk $(BASENAME).$(LANG1).dix | @AWK@ -f ./i_to_p.awk | @AWK@ -f ./sustituye_caracteres.awk > .deps/$(BASENAME).$(LANG1).dix.apos
	lt-comp lr .deps/$(BASENAME).$(LANG1).dix.apos $@ $(BASENAME).$(LANG1).acx

$(LANG1).autogen.att.gz: $(LANG1).autogen.bin
	lt-print $< | gzip -9 -c -n > $@

$(LANG1).automorf.att.gz: $(LANG1).automorf.bin
	lt-print $< | gzip -9 -c -n > $@

# Post-generator
$(LANG1).autopgen.bin: $(BASENAME).post-$(LANG1).dix
	apertium-validate-dictionary $<
	lt-comp lr $< $@

###############################################################################
## Disambiguation rules
###############################################################################

$(LANG1).rlx.bin: $(BASENAME).$(LANG1).rlx $(CGCOMP)
	$(CGCOMP) $< $@

###############################################################################
## Distribution
###############################################################################
EXTRA_DIST=$(BASENAME).$(LANG1).dix \
           $(BASENAME).$(LANG1).rlx \
           $(BASENAME).post-$(LANG1).dix \
           $(LANG1).prob            \
	   $(BASENAME).$(LANG1).tsx \
	   $(BASENAME).$(LANG1).acx \
	   modes.xml

###############################################################################
## Installation stuff
###############################################################################
#
#   apertium_ita_dir: This is where the compiled binaries go
#   apertium_ita_srcdir: This is where the source files go

apertium_itadir=$(prefix)/share/apertium/$(BASENAME)/
apertium_ita_srcdir=$(prefix)/share/apertium/$(BASENAME)/

apertium_ita_DATA=$(TARGETS_COMMON) $(LANG1).prob

pkgconfigdir = $(prefix)/share/pkgconfig
pkgconfig_DATA = $(BASENAME).pc

noinst_DATA=modes/$(LANG1)-morph.mode

install-data-local: install-modes
	test -d $(DESTDIR)$(apertium_ita_srcdir) || mkdir -p $(DESTDIR)$(apertium_ita_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).dix $(DESTDIR)$(apertium_ita_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).rlx $(DESTDIR)$(apertium_ita_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).tsx $(DESTDIR)$(apertium_ita_srcdir)

CLEANFILES = $(TARGETS_COMMON)
clean-local:
	-rm -rf .deps modes

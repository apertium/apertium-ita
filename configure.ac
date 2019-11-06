AC_PREREQ(2.52)

AC_INIT([Apertium Italian], [0.10.5], [apertium-stuff@lists.sourceforge.net], [apertium-ita], [http://wiki.apertium.org/wiki/Apertium-ita])
AM_INIT_AUTOMAKE
AC_PROG_AWK
AC_PATH_PROG(AWKPATH, $AWK, [/usr/bin/gawk])

PKG_CHECK_MODULES(APERTIUM, apertium >= 3.6.0)
PKG_CHECK_MODULES(LTTOOLBOX, lttoolbox >= 3.5.0)
PKG_CHECK_MODULES(CG3, cg3 >= 1.3.0)

AP_MKINCLUDE

AC_OUTPUT([Makefile apertium-ita.pc i_to_p.awk sustituye_caracteres.awk inline_e.awk])

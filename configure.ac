AC_PREREQ(2.52)

AC_INIT([Apertium Italian], [1.1.2], [apertium-stuff@lists.sourceforge.net], [apertium-ita], [https://wiki.apertium.org/wiki/Apertium-ita])
AM_INIT_AUTOMAKE
AC_PROG_AWK
AC_PATH_PROG(AWKPATH, $AWK, [/usr/bin/gawk])

PKG_CHECK_MODULES(APERTIUM, apertium >= 3.7.1)
PKG_CHECK_MODULES(LTTOOLBOX, lttoolbox >= 3.5.3)
PKG_CHECK_MODULES(CG3, cg3 >= 1.3.2)

PKG_CHECK_MODULES(REGTEST, apertium-regtest >= 0.0.1, [],
                  [AC_MSG_WARN([Running tests requires apertium-regtest])])

AP_MKINCLUDE

AC_OUTPUT([Makefile apertium-ita.pc i_to_p.awk sustituye_caracteres.awk inline_e.awk])

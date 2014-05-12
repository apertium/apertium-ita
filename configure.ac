AC_PREREQ(2.52)

AC_INIT([apertium-ita], [0.1.0], [ftyers@prompsit.com])
AM_INIT_AUTOMAKE([apertium-ita], [0.1.0], no-define)
AC_PROG_LN_S
AC_PROG_AWK

m4_define([required_apertium_version], [3.3.0])
PKG_CHECK_MODULES(APERTIUM,   apertium >= required_apertium_version, [], [PKG_CHECK_MODULES(APERTIUM,   apertium >= required_apertium_version)])


AC_OUTPUT([Makefile apertium-ita.pc])

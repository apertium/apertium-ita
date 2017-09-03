AC_PREREQ(2.52)

AC_INIT([apertium-ita], [0.10.0], [ftyers@prompsit.com])
AM_INIT_AUTOMAKE([apertium-ita], [0.10.0], no-define)
AC_PROG_LN_S
AC_PROG_AWK
AC_PATH_PROG(AWKPATH, $AWK,[/usr/bin/gawk])


m4_define([required_apertium_version], [3.3.0])
PKG_CHECK_MODULES(APERTIUM,   apertium >= required_apertium_version, [], [PKG_CHECK_MODULES(APERTIUM,   apertium >= required_apertium_version)])


AC_PATH_PROG(CGCOMP, cg-comp, no)
if test x$ac_cv_path_CGCOMP = x
then
  AC_MSG_ERROR([You don't have cg-comp installed.])
fi
if test x$ac_cv_path_CGPROC = xno
then
  AC_MSG_ERROR([You don't have cg-comp installed.])
fi


AP_MKINCLUDE


AC_OUTPUT([Makefile apertium-ita.pc])
AC_OUTPUT([i_to_p.awk])
AC_OUTPUT([sustituye_caracteres.awk])
AC_OUTPUT([inline_e.awk])


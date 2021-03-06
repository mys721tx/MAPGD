# ===========================================================================
# WARNING! This verision of AX_WITH_HTSLIB is not identical to the version 
# availible else where.
# ===========================================================================
#
#
# SYNOPSIS
#
#   AX_WITH_HTSLIB
#
# DESCRIPTION
#
#   This macro checks whether HTSlib <http://www.htslib.org/> is installed
#   or nearby, and adds a --with-htslib=DIR option to the configure script
#   for specifying the location.  It locates either an installation prefix
#   (with 'include' and 'lib' subdirectories) or an HTSlib source tree, as
#   HTSlib is fast-moving and users may wish to use an in-development tree.
#
#   Different checks occur depending on the --with-htslib argument given:
#
#   With --with-htslib=DIR, checks whether DIR is a source tree or contains
#     a working installation.
#   By default, searches for a source tree (with a name matching htslib*)
#     within or alongside $srcdir.  Produces AC_MSG_ERROR if there are
#     several equally-likely candidates.  If there are none, checks for
#     a working default installation.
#   With --with-htslib=system, checks for a working default installation.
#
#   If a source tree is found or specified, it is added to AC_CONFIG_SUBDIRS
#   (which unfortunately may cause a "you should use literals" warning when
#   autoconf is run).
#
#   The following output variables are set by this macro:
#
#     HTSDIR              Directory containing HTSlib source tree
#     HTSLIB_CPPFLAGS     Preprocessor flags for compiling with HTSlib
#     HTSLIB_LDFLAGS      Linker flags for linking with HTSlib
#
#   The following shell variables may be defined:
#
#     ax_cv_htslib        Set to "yes" if HTSlib was found
#     ax_cv_htslib_which  Set to "source", "install", or "none"
#
# LICENSE
#
#   Copyright (C) 2015 Genome Research Ltd
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.

#serial 1

AC_DEFUN([AX_WITH_HTSLIB],
[AC_ARG_WITH([htslib],
  [AS_HELP_STRING([--with-htslib=DIR],
    [use the HTSlib source tree or installation in DIR])
dnl Not indented, to avoid extra whitespace outwith AS_HELP_STRING()
AS_HELP_STRING([--with-htslib=system],
    [use only a system HTSlib installation])],
  [], [with_htslib=search])

case $with_htslib in
yes|search)
  AC_MSG_CHECKING([location of HTSlib source tree])
  case $srcdir in
    .) srcp= ;;
    *) srcp=$srcdir/ ;;
  esac
  found=
  for dir in ${srcp}htslib* -- ${srcp}../htslib -- ${srcp}../htslib*
  do
    if test "$dir" = "--"; then
      test -n "$found" && break
    elif test -f "$dir/hts.c" && test -f "$dir/htslib/hts.h"; then
      found="${found}1"
      HTSDIR=$dir
    fi
  done
  if test -z "$found"; then
    AC_MSG_RESULT([none found])
    ax_cv_htslib_which=system
  elif test "$found" = 1; then
    AC_MSG_RESULT([$HTSDIR])
    ax_cv_htslib_which=source
  else
    AC_MSG_RESULT([several directories found])
    AC_MSG_ERROR([use --with-htslib=DIR to select which HTSlib to use])
  fi
  ;;
no) ax_cv_htslib_which=none ;;
system) ax_cv_htslib_which=system ;;
*)
  HTSDIR=$with_htslib
  if test -f "$HTSDIR/hts.c" && test -f "$HTSDIR/htslib/hts.h"; then
    ax_cv_htslib_which=source
  else
    ax_cv_htslib_which=install
  fi
  ;;
esac

case $ax_cv_htslib_which in
source)
  dnl We can't use a literal, because $HTSDIR is user-provided and variable
  dnl AC_CONFIG_SUBDIRS($HTSDIR)
  dnl translate to absolute, anchor with './'

  HTSLIB_OLD_CPPFLAGS=$CPPFLAGS
  HTSLIB_OLD_LDFLAGS=$LDFLAGS

  if test "index("$CPPFLAGS", "$HTSDIR")" = "-1"; then

      HTSDIR=`cd ./$HTSDIR; pwd`
      HTSLIB_CPPFLAGS="-I$HTSDIR"
      HTSLIB_LDFLAGS="-L$HTSDIR"
  
      LDFLAGS="$LDFLAGS $HTSLIB_LDFLAGS"
      CPPFLAGS="$CPPFLAGS $HTSLIB_CPPFLAGS"

  fi

  AC_CHECK_LIB(m, pow)
  AC_CHECK_LIB(pthread, pthread_create)
  AC_CHECK_LIB(hts, hts_version, [ax_cv_htslib=yes], [ax_cv_htslib=no], [-lm -lpthread])

  if test ax_cv_htslib = "no"; then
    LDFLAGS="$HTSLIB_OLD_LDFLAGS"
    CPPFLAGS="$HTSLIB_OLD_CPPFLAGS"
  fi
  ;;
system)
  AC_CHECK_LIB(m, pow)
  AC_CHECK_LIB(pthread, pthread_create)
  AC_CHECK_LIB(hts, hts_version, [ax_cv_htslib=yes], [ax_cv_htslib=no], [-lm -lpthread])
  ax_cv_htslib_which=install
  HTSDIR=
  HTSLIB_CPPFLAGS=
  HTSLIB_LDFLAGS=
  ;;
install)
  HTSLIB_OLD_CPPFLAGS=$CPPFLAGS
  HTSLIB_OLD_LDFLAGS=$LDFLAGS

  if test "index("$CPPFLAGS", "$HTSDIR/lib")" = "-1"; then
    HTSDIR=
    HTSLIB_CPPFLAGS="-I$HTSDIR/include"
    HTSLIB_LDFLAGS="-L$HTSDIR/lib"
    LDFLAGS="$LDFLAGS $HTSLIB_LDFLAGS"
    CPPFLAGS="$CPPFLAGS $HTSLIB_CPPFLAGS"
  fi

  AC_CHECK_LIB(m, pow)
  AC_CHECK_LIB(pthread, pthread_create)
  AC_CHECK_LIB(hts, hts_version, [ax_cv_htslib=yes], [ax_cv_htslib=no], [-lm -lpthread])

  if test ax_cv_htslib = "no"; then
    LDFLAGS="$HTSLIB_OLD_LDFLAGS"
    CPPFLAGS="$HTSLIB_OLD_CPPFLAGS"
  fi
  ;;
none)
  ax_cv_htslib=no
  ;;
esac

AC_SUBST([HTSDIR])
AC_SUBST([HTSLIB_CPPFLAGS])
AC_SUBST([HTSLIB_LDFLAGS])])

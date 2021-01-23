#!/bin/bash

# Script and meta.yaml taken from https://github.com/AnacondaRecipes/aggregate/blob/088dd9dc0296bd0e5fdba1b3d2f2c2babd359327/crosstool-ng-feedstock/recipe/build.sh

export EXTRA_CFLAGS="-I${PREFIX}/include -I${PREFIX}/include/ncurses"
if [[ ${target_platform} =~ .*inux ]]; then
  # -rpath-link is needed because libncursesw.so depends upon libtinfo.so and
  # configure will fail to find ncurses without it if using the conda ncurses
  # package.
  export EXTRA_LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lncursesw"
  export CPPFLAGS="-I${PREFIX}/include -L${PREFIX}/lib -Wl,-rpath-link,${PREFIX}/lib"
else
  export CPPFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
fi

# These get baked into paths.mk but we do not relocate them nor add
# run requirements for them.
unset LIBTOOL
unset LIBTOOLIZE
unset OBJCOPY
unset OBJDUMP
unset READELF
export BASH="/usr/bin/env bash"
export AWK="/usr/bin/env gawk"
export GREP="/usr/bin/env grep"
export MAKE="/usr/bin/make"
export SED="/usr/bin/env sed"
export OBJCOPY="/usr/bin/env objcopy"
export OBJDUMP="/usr/bin/env objdump"
export READELF="/usr/bin/env readelf"
export PATCH="/usr/bin/env patch"
export GPERF="/usr/bin/env gperf"
# Rather than unsetting all these it may be easier to pass -c to bash
# when we call bootstrap.
unset ncurses expat autoconf automake binutils bison cloog dtc duma \
      elf2flt expat gcc gdb gettext glibc gmp isl libelf libiconv \
      libtool linux ltrace m4 make moxiebox mpc mpfr musl ncurses \
      newlib picolibc strace zlib

mkdir tmp
mv $SRC_DIR/packages/glibc/2.17/*-glibc-*.patch tmp

if [[ $(uname) == Darwin ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib
fi
getconf ARG_MAX
./bootstrap
./configure --prefix=${PREFIX} || (cat config.log && exit 1)
make -j${CPU_COUNT} ${VERBOSE_AT}
make install

mv tmp/*.patch $PREFIX/share/crosstool-ng/packages/glibc/2.17/

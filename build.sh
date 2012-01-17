#!/bin/sh

# Want to ensure we are using the right tools to build
# this thing.
PATH=/usr/bin:/bin
export PATH

# The standard GNU triplet.
#  HOST is the environment where the toolchain will run.
#  TARGET is the environment that the compiler will generate binaries for
#  BUILD is the environment in which the toolchain is being built
HOST=x86_64-apple-darwin
BUILD=$HOST
TARGET=arm-none-eabi

BUILDBASE=${BUILDBASE-$(pwd)/build}

PAR=-j8

STANDARD_LDFLAGS="-Wl,-Z -Wl,-search_paths_first -L$(pwd)/devtree/$HOST/lib"
STANDARD_CPPFLAGS="-I$(pwd)/devtree/$HOST/include"

# binutils package
build_binutils()
{
PACKAGE=binutils
PACKAGEDIR=$(pwd)/source/$PACKAGE

PREFIX=/noprefix
EPREFIX=$PREFIX/$HOST

BUILDROOT=$BUILDBASE/$PACKAGE-$HOST-$TARGET
INSTALLROOT=$(pwd)/install


rm -fr $BUILDROOT &&
mkdir $BUILDROOT &&
(cd $BUILDROOT;
    LDFLAGS=$STANDARD_LDFLAGS $PACKAGEDIR/configure \
        --prefix=$PREFIX \
        --exec-prefix=$EPREFIX \
        --program-prefix=$TARGET- \
        --host=$HOST \
        --build=$BUILD \
        --target=$TARGET \
        --disable-nls \
        --enable-lto \
        --enable-ld=yes \
        &&
    make $PAR &&
    make DESTDIR=$INSTALLROOT install
)
}

build_devtree_pkg ()
{
    PACKAGE=$1
    PACKAGEDIR=$(pwd)/source/$PACKAGE

    PREFIX=$(pwd)/devtree
    EPREFIX=$PREFIX/$HOST

    BUILDROOT=$BUILDBASE/$PACKAGE-$HOST

    rm -fr $BUILDROOT &&
    mkdir $BUILDROOT &&
    (cd $BUILDROOT;
        LDFLAGS=$STANDARD_LDFLAGS \
        CPPFLAGS=$STANDARD_CPPFLAGS \
        $PACKAGEDIR/configure \
            --prefix=$PREFIX \
            --exec-prefix=$EPREFIX \
            --program-prefix=$TARGET- \
            --host=$HOST \
            --build=$BUILD \
            --disable-shared \
            &&
        make $PAR &&
        make install
    )
}

# gmp package
build_gmp ()
{
    build_devtree_pkg gmp
}

# mpfr package
build_mpfr ()
{
    build_devtree_pkg mpfr
}

build_mpfr

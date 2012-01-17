#!/bin/sh

# Want to ensure we are using the right tools to build
# this thing.
PATH=/usr/bin:/bin:$(pwd)/install/noprefix/x86_64-apple-darwin/bin/:/usr/local/bin
export PATH

# The standard GNU triplet.
#  HOST is the environment where the toolchain will run.
#  TARGET is the environment that the compiler will generate binaries for
#  BUILD is the environment in which the toolchain is being built
HOST=x86_64-apple-darwin
BUILD=$HOST
TARGET=arm-none-eabi

BUILDBASE=${BUILDBASE-$(pwd)/build}

PAR=${PAR--j8}

DEVTREE=$(pwd)/devtree
DEVTREE_HOST=$DEVTREE/$HOST

STANDARD_LDFLAGS="-Wl,-Z -Wl,-search_paths_first -L$DEVTREE_HOST/lib"
STANDARD_CPPFLAGS="-I$DEVTREE -I$DEVTREE_HOST/include"

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

# gcc package
build_gcc()
{
    PACKAGE=gcc
    PACKAGEDIR=$(pwd)/source/$PACKAGE

    PREFIX=/noprefix
    EPREFIX=$PREFIX/$HOST

    BUILDROOT=$BUILDBASE/$PACKAGE-$HOST-$TARGET
    INSTALLROOT=$(pwd)/install


    rm -fr $BUILDROOT &&
    mkdir $BUILDROOT &&
    (cd $BUILDROOT;
        LDFLAGS=$STANDARD_LDFLAGS \
        $PACKAGEDIR/configure \
            --prefix=$PREFIX \
            --exec-prefix=$EPREFIX \
            --program-prefix=$TARGET- \
            --host=$HOST \
            --build=$BUILD \
            --target=$TARGET \
            --disable-shared \
            --disable-lto \
            --disable-nls \
            --enable-languages=c \
            --disable-libssp \
            --disable-libquadmath \
            --disable-libgomp \
            --disable-libgcj \
            --with-gnu-as \
            --with-gnu-ld \
            --with-gmp=$DEVTREE_HOST \
            --with-mpfr-lib=$DEVTREE_HOST/lib \
            --with-mpfr-include=$DEVTREE/include \
           \
            &&
        make $PAR &&
        make DESTDIR=$INSTALLROOT install
    )
}



# gdb package
build_gdb()
{
PACKAGE=gdb
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

# mpc package
build_mpc ()
{
    build_devtree_pkg mpc
}

# gettext package
build_gettext ()
{
    build_devtree_pkg gettext
}


build_gettext

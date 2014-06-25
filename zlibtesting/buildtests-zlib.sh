#!/bin/bash -e

DEBIANVERSION=1:1.2.7.dfsg-13
DEBIANVERSIONNOEPOCH=`echo $DEBIANVERSION |sed 's/^.*://'`
PACKAGENAME=zlib

TOPDIR=`pwd`
TESTDIR=$TOPDIR/testpackages
rm -rf testpackages
mkdir testpackages

dcmd cp -l ${PACKAGENAME}_${DEBIANVERSIONNOEPOCH}.dsc testpackages

for OPT in -Os -O2 -O3; do
  for COMPILER in gcc-4.6 gcc-4.7 gcc-4.8; do
    VERSIONSUFFIX=`echo +rptest+$COMPILER+$OPT | sed 's/ /+/g' | tr -s + | sed 's/+$//' `
    VERSION=${DEBIANVERSION}${VERSIONSUFFIX}
    VERSIONNOEPOCH=${DEBIANVERSIONNOEPOCH}${VERSIONSUFFIX}
    cd $TESTDIR
    dpkg-source -x ${PACKAGENAME}_${DEBIANVERSIONNOEPOCH}.dsc $PACKAGENAME_${VERSIONNOEPOCH}
    cd $PACKAGENAME_${VERSIONNOEPOCH}
    sed "s/__OPT__/$OPT/" $TOPDIR/${PACKAGENAME}-opttemplate.debdiff | sed s/__COMPILER__/$COMPILER/ | sed s/__VERSIONSUFFIX__/$VERSIONSUFFIX/ | patch -p1
    dpkg-buildpackage -b -us -uc
  done

done




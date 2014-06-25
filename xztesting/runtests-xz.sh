#!/bin/bash -e

DEBIANVERSION=5.1.1alpha+20120614-2
DEBIANVERSIONNOEPOCH=`echo $DEBIANVERSION |sed 's/^.*://'`
PACKAGENAME=xz-utils

TOPDIR=`pwd`
TESTDIR=$TOPDIR/testpackages
TESTDATADIR=$TOPDIR/testdata
TESTRESULTSDIR=$TOPDIR/testresults
TESTTMPDIR=/run/pgbenchmarks

rm -rf ${TESTRESULTSDIR}
mkdir ${TESTRESULTSDIR}
rm -rf ${TESTTMPDIR}
mkdir ${TESTTMPDIR}

for OPT in -Os -O2 -O3; do
  for COMPILER in gcc-4.6 gcc-4.7 gcc-4.8; do
    VERSIONSUFFIX=`echo +rptest+$COMPILER+$OPT | sed 's/ /+/g' | tr -s + | sed 's/+$//' `
    VERSION=${DEBIANVERSION}${VERSIONSUFFIX}
    VERSIONNOEPOCH=${DEBIANVERSIONNOEPOCH}${VERSIONSUFFIX}
    dcmd --deb dpkg -i ${TESTDIR}/${PACKAGENAME}_${VERSIONNOEPOCH}_armhf.changes
    cd ${TESTDATADIR}
    for FILE in *; do
      cp $FILE $TESTTMPDIR
      cd $TESTTMPDIR
      rm -f ${VERSIONNOEPOCH}.*compressresults
      #note: bash has a built in called time which we don't want to use
      #sync disks to minimise chance of pending disc writes messing with our result
      sync
      #run the test a few times discarding the results to let the system stabalise
      for (( i=0; i < 10; i++ )); do
        echo $i
        rm -f $FILE.xz
        `which time` -o /dev/null -a xz --keep $FILE
      done
      for (( i=0; i < 100; i++ )); do
        echo $i
        rm -f $FILE.xz
        `which time` -o ${VERSIONNOEPOCH}.$FILE.compressresults -a xz --keep $FILE
      done
      #run the tests a few times discarding the results to let the system stabalise
      for (( i=0; i < 100; i++ )); do
        echo $i
        `which time` -o /dev/null -a xzcat $FILE.xz > /dev/null
      done
      for (( i=0; i < 1000; i++ )); do
        echo $i
        `which time` -o ${VERSIONNOEPOCH}.$FILE.decompressresults -a xzcat $FILE.xz > /dev/null
      done
      rm -f $FILE
      rm  -f $FILE.xz
      cp ${VERSIONNOEPOCH}.*compressresults $TESTRESULTSDIR || bash
      cd $TESTDATADIR
    done

  done

done



#!/bin/bash -e

DEBIANVERSION=1:1.2.7.dfsg-13
DEBIANVERSIONNOEPOCH=`echo $DEBIANVERSION |sed 's/^.*://'`
PACKAGENAME=zlib

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
    dcmd --deb dpkg -i ${TESTDIR}/zlib_${VERSIONNOEPOCH}_armhf.changes
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
        rm -f test.zip
        `which time` -o /dev/null -a minizip test.zip $FILE
      done
      for (( i=0; i < 100; i++ )); do
        echo $i
        rm -f test.zip
        `which time` -o ${VERSIONNOEPOCH}.$FILE.compressresults -a minizip test.zip $FILE
      done
      #run the tests a few times discarding the results to let the system stabalise
      for (( i=0; i < 1000; i++ )); do
        echo $i
        rm -f $FILE
        `which time` -o /dev/null -a miniunzip test.zip
      done
      for (( i=0; i < 1000; i++ )); do
        echo $i
        rm -f $FILE
        `which time` -o ${VERSIONNOEPOCH}.$FILE.decompressresults -a miniunzip test.zip
      done
      for (( i=0; i < 1000; i++ )); do
        echo $i
        rm -f $FILE
        `which time` -o ${VERSIONNOEPOCH}.$FILE.decompressresults -a miniunzip test.zip
      done
      rm -f test.zip
      rm  -f $FILE
      cp ${VERSIONNOEPOCH}.*compressresults $TESTRESULTSDIR || bash
      cd $TESTDATADIR
    done

  done

done




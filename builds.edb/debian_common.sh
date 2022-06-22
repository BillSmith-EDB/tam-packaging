#!/bin/bash

cwd=`pwd`
echo "::group::environment dump"
env
echo "::endgroup::"

echo "::group::postgresql configure"
# Need to add --enable-tap-tests and --with-default-tam=refdata
./configure --without-readline
if [ $? -ne 0 ]; then
    echo "ERROR: configure step failed. Exiting"
    exit $?
fi      
echo "::endgroup::"


echo "::group::building postgresql and extensions"
make
if [ $? -ne 0 ]; then
    echo "ERROR: make step failed. Exiting"
    exit $?
fi    
echo "::endgroup::"

echo "::group::running tests"
make check 2>&1  | tee all_tests.log
if [ $? -ne 0 ]; then
    echo "ERROR: make check step failed. Exiting"
    exit $?
fi
grep --extended-regexp 'All \d+ tests passed' all_tests.log
if [ $? -ne 0 ]; then
    echo "ERROR: one or more tests failed. Check the logfile for details"
    exit $?
fi
echo "::endgroup::"

cd $cwd
mkdir -p debian
touch debian/bogus_artifact
ls -l debian

exit 0


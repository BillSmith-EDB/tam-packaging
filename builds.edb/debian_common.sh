#!/bin/bash

cwd=`pwd`
echo "::group::environment dump"
env
echo "::endgroup::"

if [ -z "$TAM_TYPE" ]; then
    echo "ERROR: TAM_TYPE environment variable is not set.  Needs to be set to a valid tam"
    exit 1
fi

echo "::group::apt-get installation of missing packages"
set -x
sudo apt-get install -y libreadline-dev libghc-zlib-dev libxml2 libxml2-dev flex bison libz-dev xml2 libxslt1-dev
set +x
echo "::endgroup::"

echo "::group::postgresql configure"
# Need to add --enable-tap-tests and --with-default-tam=refdata
set -x
cd tam
./configure --without-readline --with-alternate-tam=$TAM_TYPE
set +x
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
set -x
grep 'tests passed' all_tests.log

grep --extended-regexp 'All [0-9]+ tests passed' all_tests.log
if [ $? -ne 0 ]; then
    echo "ERROR: one or more tests failed. Check the logfile for details"
    exit $?
fi
set +x
echo "::endgroup::"

cd $cwd
mkdir -p debian
touch debian/bogus_artifact
ls -l debian

exit 0


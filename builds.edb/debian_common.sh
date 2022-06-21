#!/bin/bash

cwd=`pwd`
echo "::group::apt-get installation of missing packages"
cd tam
set -x
sudo apt-get install -y libreadline-dev libghc-zlib-dev libxml2 libxml2-dev flex bison libz-dev xml2 libxslt1-dev
set +x
echo "::endgroup::"


echo "::group::postgresql configure"
./configure --without-readline
if [ $? -ne 0 ]; then
    echo "ERROR: configure step failed. Exiting"
    exit $?
fi      
echo "::endgroup::"


echo "BEGIN: Running build step"
make
if [ $? -ne 0 ]; then
    echo "ERROR: make step failed. Exiting"
    exit $?
fi    
echo "END: Running build step"

echo "BEGIN: Running tests"
make check 2>&1  | tee all_tests.log
if [ $? -ne 0 ]; then
    echo "ERROR: make check step failed. Exiting"
    exit $?
fi    
echo "END: Running tests"

cd $cwd
mkdir -p debian
touch debian/bogus_artifact
ls -l debian

exit 0


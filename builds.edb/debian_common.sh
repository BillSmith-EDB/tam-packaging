#!/bin/bash

cwd=`pwd`
echo "Add code to build packages here. Currently in directory: $cwd"
cd tam
echo "BEGIN: Running apt-get step to install missing packages"
set -x
sudo apt-get install -y libreadline-dev libghc-zlib-dev libxml2 libxml2-dev flex bison libz-dev xml2 libxslt1-dev
set +x

echo "END: Running apt-get step to install missing packages"

echo "BEGIN: Running configure step"
./configure --without-readline
if [ $? -ne 0 ]; then
    echo "ERROR: configure step failed. Exiting"
    exit $?
fi      
echo "END: Running configure step"

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


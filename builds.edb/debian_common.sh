#!/bin/bash

cwd=`pwd`
echo "Add code to build packages here. Currently in directory: $cwd"
cd tam
echo "BEGIN: Running apt-get step to install missing packages"
sudo apt-get -y readline zlib
echo "END: Running apt-get step to install missing packages"

echo "BEGIN: Running configure step"
./configure --without-readline
if [ $? -ne 0 ]; then
    echo "ERROR: configure step failed. Exiting"
fi      
echo "END: Running configure step"

echo "BEGIN: Running build step"
make
if [ $? -ne 0 ]; then
    echo "ERROR: make step failed. Exiting"
fi    
echo "END: Running build step"

echo "BEGIN: Running tests"
make check
if [ $? -ne 0 ]; then
    echo "ERROR: make check step failed. Exiting"
fi    
echo "END: Running tests"

mkdir debian
touch debian/bogus_artifact
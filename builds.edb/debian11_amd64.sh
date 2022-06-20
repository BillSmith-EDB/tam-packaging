#!/bin/bash

cwd=`pwd`
echo "Add code to build packages here. Currently in directory: $cwd"
cd tam
echo "BEGIN: Running configure step"
./configure
echo "END: Running configure step"

echo "BEGIN: Running build step"
make
echo "END: Running build step"

echo "BEGIN: Running tests"
make check
echo "END: Running tests"

mkdir debian
touch debian/bogus_artifact



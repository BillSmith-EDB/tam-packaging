#!/bin/bash

cwd=`pwd`
mkdir -p artifacts

echo "::group::environment dump"
env
echo "::endgroup::"

if [ -z "$TAM_TYPE" ]; then
    echo "::error:: TAM_TYPE environment variable is not set.  Needs to be set to a valid tam"
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
    echo "::error:: configure step failed. Exiting"
    exit $?
fi      
echo "::endgroup::"


echo "::group::building postgresql and extensions"
make
if [ $? -ne 0 ]; then
    echo "::error:: make step failed. Exiting"
    exit $?
fi    
echo "::endgroup::"

echo "::group::running tests"
make check 2>&1  | tee all_tests.log
if [ $? -ne 0 ]; then
    echo "::error:: make check step failed. Exiting"
    exit $?
fi
set -x
grep 'tests passed' all_tests.log

grep --extended-regexp 'All [0-9]+ tests passed' all_tests.log
if [ $? -ne 0 ]; then
    echo "::error:: one or more tests failed:"
    grep '... FAILED' all_tests.log
    echo "### Tests failed" >> $GITHUB_STEP_SUMMARY
    grep '... FAILED' all_tests.log | awk '{print $1}' >> $GITHUB_STEP_SUMMARY
    cp src/test/regress/regression.out $cwd/artifacts
    exit $?
fi
set +x
echo "::endgroup::"

cd $cwd
mkdir -p debian
touch debian/bogus_artifact
ls -l debian

exit 0


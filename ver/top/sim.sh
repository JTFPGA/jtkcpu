#!/bin/bash

# reassemble the ucode
cd ../../src
go run uasm.go || exit $?
cd -

TEST=$1

if [ -z "$ASPATH" ]; then
    ASPATH=`which asl`
    ASPATH=${ASPATH%asl}
else
    ASPATH="$ASPATH"/
fi

if [ ! -e "tests/$TEST".asm ]; then
    echo "Cannot find $TEST.asm in tests"
    exit 1
fi

if ! ${ASPATH}asl -cpu 052001 tests/$TEST.asm -l > asl.log; then
    grep -A 2 error: asl.log
    exit 1
fi

if ! ${ASPATH}p2bin tests/$TEST.p >> asl.log; then
    cat asl.log;
    exit 1
fi

mv tests/$TEST.bin test.bin
rm -f tests/$TEST.p

iverilog test.v ../../hdl/*.v -I../../hdl -o sim && sim -lxt
rm -f sim

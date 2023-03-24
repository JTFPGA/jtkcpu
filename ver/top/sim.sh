#!/bin/bash

TEST=$1

if [ ! -e "tests/$TEST".asm ]; then
    echo "Cannot find $TEST.asm in tests"
    exit 1
fi

asl -cpu 6809 tests/$TEST.asm > asl.log || (cat asl.log; exit 1)
p2bin tests/$TEST.p >> asl.log || ( cat asl.log; exit 1)
mv tests/$TEST.bin test.bin
rm -f tests/$TEST.p

iverilog test.v ../../hdl/*.v -I../../hdl -o sim && sim -lxt
rm -f sim

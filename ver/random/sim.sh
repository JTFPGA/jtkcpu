#!/bin/bash

cd ../../src
go run uasm.go || exit $?
cd -
verilator ../../hdl/*.v -I../../hdl \
    --top-module jtkcpu -o sim --trace -DJTKCPU_DEBUG \
    --cc test.cpp --exe --prefix UUT || exit $?

if ! make -j -C obj_dir -f UUT.mk sim > make.log; then
    cat make.log
    exit $?
fi

obj_dir/sim
#!/bin/bash

# reassemble the ucode
cd ../../src
go run uasm.go || exit $?
cd -

parallel sim.sh --batch ::: `cd tests;ls *.asm` | tee batch.log
if grep --quiet FAIL batch.log; then
    echo -e "\nFailing tests:"
    grep FAIL batch.log
fi
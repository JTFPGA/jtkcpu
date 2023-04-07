#!/bin/bash

TEST=
BATCH=
SIMID=`printf "%04X%04X" $RANDOM $RANDOM`
NODUMP=

while [ $# -gt 0 ]; do
    case $1 in
        -b|--batch)
            BATCH=1;;
        *)
            if [ -z "$TEST" ]; then
                TEST=$1
            else
                echo "Unknown argument $1"
                exit 1
            fi;;
    esac
    shift
done

if [ -z "$TEST" ]; then
    echo "You must specify a test name"
    exit 1
fi

TEST=${TEST%%.asm}

if [ -z "$BATCH" ]; then
    ASLLOG=asl.log
    SIMID=test
    # reassemble the ucode
    cd ../../src
    go run uasm.go || exit $?
    cd -
    verilator --lint-only ../../hdl/*.v -I../../hdl || exit $?
else
    ASLLOG=/tmp/$SIMID.log
    NODUMP=-DNODUMP
fi

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

if ! ${ASPATH}asl -cpu 052001 tests/$TEST.asm -l > $ASLLOG; then
    echo "${TEST}: "
    grep -A 2 error: $ASLLOG
    exit 1
fi

if ! ${ASPATH}p2bin tests/$TEST.p >> $ASLLOG; then
    cat $ASLLOG;
    exit 1
fi


mv tests/$TEST.bin $SIMID.bin
rm -f tests/$TEST.p

iverilog -I../../hdl $NODUMP -DSIMULATION -Ptest.SIMID=\"$SIMID\" -o $SIMID.sim test.v ../../hdl/*.v || exit 1

if [ -z "$BATCH" ]; then
    $SIMID.sim -lxt | tee $SIMID.log
else
    $SIMID.sim > $SIMID.log
fi

rm -f $SIMID.sim
if grep --quiet PASS $SIMID.log; then
    EXITCODE=0
    echo -e "$TEST\tPASS"
else
    EXITCODE=1
    echo -e "$TEST\tFAIL"
fi

if [ ! -z "$BATCH" ]; then
    rm -f $ASLLOG $SIMID.log $SIMID.bin
fi
exit $EXITCODE
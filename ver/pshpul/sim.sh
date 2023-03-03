#!/bin/bash

iverilog  -o sim ../../hdl/jtkcpu_regs.v test.v && sim -lxt
rm -f sim
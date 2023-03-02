#!/bin/bash

iverilog  -o sim ../../hdl/jtkcpu_div.v test.v && sim -lxt
rm -f sim
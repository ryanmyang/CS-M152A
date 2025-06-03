#!/bin/bash
iverilog  src/basys3_tb.v src/basys3.v src/DisplayController.v src/KeypadInput.v
./a.out
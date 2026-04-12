# Parameterized Barrel Shifter

## Overview

Computes both logical and arithmetic left and right shifts, purely cominational. Parameterized for customizable data widths. Doesn't use the shift operators, `<<` and `>>`, for learning purposes.


## Architecture

**Parameters**
- `DATA_W` - input data operand width (default: 32)
- `SHAMT_W` - input shift amount operand width (default: 5)

**Interface**

| Signal       | Dir | Width      | Description                            |
|--------------|-----|------------|----------------------------------------|
| `data_in`    | in  | DATA_W     | Data input                             |
| `shamt`      | in  | SHAMT_W    | Shift Amount                           |
| `mode`       | in  | 2          | Mode select                            |
| `data_out`   | out | DATA_W     | Shifted output                         |

## Running Simulations

Verilator: 
```
verilator --cc --exe --build --trace BarrelShifter.sv BarrelShifter.cpp
```
Trace files are dumped for waveform viewing

Symbiyosys:
```
sby -f BarrelShifter.sby
```
Proven to depth 1 (It's all combinational)

## Formal Verification

Mode contract: Does the mode input correctly choose between modes?
Also checks correct shift functionality

Empty Shift: If shamt == 0, does the shifter do nothing?

Sign extension functionality: Does the arithmetic right mode exhibit correct sign extension behavior?

## Potential improvements
1. It is probably a good idea to move the case statement inside the for loop. Current implementation creates multiple shift networks. The change would make the design take up significantly less area.


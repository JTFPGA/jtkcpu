# JTKCPU

Verilog core compatible with Konami's 052001

You can show your appreciation through
* [Patreon](https://patreon.com/jotego), by supporting releases
* [Paypal](https://paypal.me/topapate), with a donation

# Assembler

[Alfred Arnold's assembler](http://john.ccac.rwth-aachen.de:8000/as/index.html) supports the 052001 instruction set. The [top-level simulations](ver/top/sim.sh) expect this assembler in the system to run the unit tests.

# Game Library

The following games used the 052001 CPU as the main or sound processor. The set names and source files refer to the MAME emulator

Games                                        | Setname        | Source         |      Audio               | CPUs
---------------------------------------------|----------------|----------------|--------------------------|------------
'88 Games                                    | 88games        | 88games.cpp    | YM2151,          uPD7759 | KCPU, Z80
Ajax                                         | ajax           | ajax.cpp       | YM2151, K007232          | KCPU, Z80, HD63089
Aliens (World set 1)                         | aliens         | aliens.cpp     | YM2151, K007232          | KCPU, Z80
Block Hole                                   | blockhl        | blockhl.cpp    | YM2151                   | KCPU, Z80
Chequered Flag                               | chqflag        | chqflag.cpp    | YM2151, K007232          | KCPU, Z80
Crazy Cop (Japan)                            | crazycop       | thunderx.cpp   | YM2151, K007232          | KCPU, Z80
Crime Fighters (World 2 players)             | crimfght       | crimfght.cpp   | YM2151, K007232          | KCPU, Z80
Escape Kids (Asia, 4 Players)                | esckids        | vendetta.cpp   | YM2151,          K053260 | KCPU, Z80
Gang Busters (set 1)                         | gbusters       | thunderx.cpp   | YM2151, K007232          | KCPU, Z80
Haunted Castle (version M)                   | hcastle        | hcastle.cpp    | YM3812, K007232, K053260 | KCPU, Z80
Parodius DA! (World, set 1)                  | parodius       | parodius.cpp   | YM2151,          K053260 | KCPU, Z80
Quarth (Japan)                               | quarth         | blockhl.cpp    | YM2151                   | KCPU, Z80
Rollergames (US)                             | rollerg        | rollerg.cpp    | YM3812,          K053260 | KCPU, Z80
Super Contra (set 1)                         | scontra        | thunderx.cpp   | YM2151, K007232          | KCPU, Z80
The Simpsons (4 Players World, set 1)        | simpsons       | simpsons.cpp   | YM2151,          K053260 | KCPU, Z80
Surprise Attack (World ver. K)               | suratk         | surpratk.cpp   | YM2151                   | KCPU
Thunder Cross (set 1)                        | thunderx       | thunderx.cpp   | YM2151                   | KCPU, Z80
Vendetta (World, 4 Players, ver. T)          | vendetta       | vendetta.cpp   | YM2151,          K053260 | KCPU, Z80

# Resource Usage

Compiled on a Cyclone III EP3C25 (the FPGA in MiST), resource usage is:

Item            | Usage
----------------|---------
Logic Elements  |  2,290
Memory bits     | 12,800
Multipliers     |      3

Fmax > 70 MHz
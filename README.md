# JTKCPU

Verilog core compatible with Konami's 052001

You can show your appreciation through
* [Patreon](https://patreon.com/jotego), by supporting releases
* [Paypal](https://paypal.me/topapate), with a donation

# Assembler

[Alfred Arnold's assembler](http://john.ccac.rwth-aachen.de:8000/as/index.html) supports the 052001 instruction set. The [top-level simulations](ver/top/sim.sh) expect this assembler in the system to run the unit tests.

# Game Library

The following games used the 052001 CPU as the main or sound processor. The set names and source files refer to the MAME emulator

Games                                        | Setname        | Source
---------------------------------------------|----------------|------------
'88 Games                                    | 88games        | 88games.cpp
Ajax                                         | ajax           | ajax.cpp
Ajax (Japan)                                 | ajaxj          | ajax.cpp
Aliens (World set 1)                         | aliens         | aliens.cpp
Block Hole                                   | blockhl        | blockhl.cpp
Chequered Flag                               | chqflag        | chqflag.cpp
Chequered Flag (Japan)                       | chqflagj       | chqflag.cpp
Crazy Cop (Japan)                            | crazycop       | thunderx.cpp
Crime Fighters (World 2 players)             | crimfght       | crimfght.cpp
Escape Kids (Asia, 4 Players)                | esckids        | vendetta.cpp
Gang Busters (set 1)                         | gbusters       | thunderx.cpp
Haunted Castle (version M)                   | hcastle        | hcastle.cpp
Parodius DA! (World, set 1)                  | parodius       | parodius.cpp
Quarth (Japan)                               | quarth         | blockhl.cpp
Rollergames (US)                             | rollerg        | rollerg.cpp
Rollergames (Japan)                          | rollergj       | rollerg.cpp
Super Contra (set 1)                         | scontra        | thunderx.cpp
The Simpsons (4 Players World, set 1)        | simpsons       | simpsons.cpp
Surprise Attack (World ver. K)               | suratk         | surpratk.cpp
Thunder Cross (set 1)                        | thunderx       | thunderx.cpp
Typhoon                                      | typhoon        | ajax.cpp
Vendetta (World, 4 Players, ver. T)          | vendetta       | vendetta.cpp

# Resource Usage

Compiled on a Cyclone III EP3C25 (the FPGA in MiST), resource usage is:

Item            | Usage
----------------|---------
Logic Elements  |  2,290
Memory bits     | 12,800
Multipliers     |      3

Fmax = 52.39 MHz
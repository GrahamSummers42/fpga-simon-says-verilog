# FPGA Simon Says Game

Simon Says-style memory game implemented in Verilog on a Xilinx Spartan-7 XC7S50 FPGA using Vivado.

## Overview

This project was developed as a personal initiative project for a Digital Logic course. The FPGA generates a growing sequence of LED flashes that the player must memorize and reproduce using four push buttons.

The design uses modular Verilog logic for pseudo-random number generation, sequence storage and playback, synchronized user input, game-state control, timing, scoring, and seven-segment display output.

## Demo

[Watch the FPGA Simon Says demo](media/Simon_says_demo.mp4)

## Key Features

- Xilinx Spartan-7 XC7S50 FPGA
- Verilog HDL
- Finite-state machine game control
- Pseudo-random sequence generation using a free-running counter
- Four-step sequence storage and playback
- Synchronized push-button input with edge detection
- Timer-controlled LED sequencing
- Seven-segment score display
- Win and game-over LED animations

## Game Operation

The game begins by generating a pseudo-random value from the lower two bits of a continuously running counter. Each 2-bit value corresponds to one of four LEDs.

The generated value is added to a stored sequence. The FPGA plays the current sequence by flashing the corresponding LEDs, and the player then reproduces the pattern using four push buttons.

Each button input is compared against the corresponding stored sequence value. Correct inputs allow the game to continue and add another value to the sequence. An incorrect input resets the sequence and score and triggers a game-over animation.

Successfully completing the four-step sequence increments the score and triggers a win animation.

## Design Architecture

The Verilog design contains several modules:

- `randomNum` - generates 2-bit pseudo-random values using a free-running counter
- `simulatingSequence` - stores and plays back the LED sequence
- `timer` - controls LED playback and animation timing
- `syncN` - synchronizes external button inputs to the FPGA clock
- `userInput` - detects new button presses and converts them to 2-bit values
- `fsm` - controls game progression, input checking, scoring, and animations
- `sevenSeg` - displays the score on the seven-segment display
- `top` - connects the modules to the FPGA inputs and outputs

## Repository Structure

```text
fpga-simon-says/
├── README.md
├── src/
│   └── simon_says.v
├── constraints/
│   └── board.xdc
└── media/
    └── simon-says-demo.mp4

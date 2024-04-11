# Game of Life on FPGA

![Alt text](img/screen.jpg?raw=true "Title")

This project implements the classic Game of Life cellular automaton on an FPGA using Verilog. The Game of Life is a zero-player game where the evolution of cells on a grid is determined by a set of rules based on the state of neighboring cells.

## Features

- Implements the Game of Life on an FPGA
- Utilizes a double dual-port framebuffer for efficient cell state storage
- Generates a random initial state using a linear feedback shift register (LFSR)
- Displays the game state on an LCD screen using a VGA controller
- Supports a grid size of 480x272 cells

## Hardware Requirements

- FPGA development board with sufficient logic resources
- LCD screen with VGA interface
- Clock input and reset button

## Modules

![Alt text](img/top.jpg?raw=true "Title")

### TOP

The top-level module that instantiates and connects all the submodules. It takes the clock input, reset button, and LCD output signals as ports.

### div

A clock divider module that generates a divided clock signal based on the specified ratio.

### lfsr

A linear feedback shift register module that generates pseudo-random numbers for initializing the game state.

### double_dual_port_framebuffer

A dual-port framebuffer module that stores the cell states. It utilizes two Gowin_DPB (dual-port block RAM) instances to enable simultaneous read and write operations.

### vga

A VGA controller module that generates the necessary timing signals for displaying the game state on an LCD screen.

### gol

The Game of Life engine module that implements the rules and updates the cell states. It iterates over the grid, calculates the number of live neighbors for each cell, and determines the next state based on the rules.

## Usage

1. Synthesize and implement the project on your FPGA development board using the appropriate tools.
2. Connect the LCD screen to the FPGA board using the VGA interface.
3. Provide a clock input to the `CLK_IN` port and ensure it meets the required frequency.
4. Use the `BUTTON1` input as the reset button to initialize the game state.
5. The game will start automatically, and the cell states will be displayed on the LCD screen.

## Customization

- Modify the `WIDTH` and `HEIGHT` parameters in the `gol` module to change the grid size.
- Adjust the clock divider ratio in the `div` module to control the game speed.
- Customize the color scheme by modifying the assignments to `LCD_R`, `LCD_G`, and `LCD_B` in the `TOP` module.

## License

This project is open-source and available under the [MIT License](LICENSE).

## Acknowledgments

- The Game of Life was originally created by mathematician John Conway.
- The FPGA implementation is based on the Verilog language and utilizes Gowin FPGA primitives.

Feel free to explore and modify the code to enhance the functionality or adapt it to your specific requirements. Enjoy playing the Game of Life on your FPGA!



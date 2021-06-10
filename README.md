# Floating-Point-Co-Processor
## Chuck Faber, Bhargavi Chunchu, Ramprakash Baskar, Keerthan Nayak

For this project, we attempted to implmement a IEEE 754 single precision floating point processor in SystemVerilog.

### Contents
 - /docs/: Includes the final presentation report
 - /src/: Includes all source files
    - /design/: Includes the module design files.
    - /verification/: Includes the testbenches and verification files.
        - add_sub_top_tb.sv: Our main top level testbench.
    - /dev/: This folder includes test code and other code snippets
    - makefile: This makefile includes compilation and simulation targets.

### Building and Simulating
This design has been built and tested on QuestaSim installed on the 
auto.ece.pdx.edu server and run through the terminal.

1. Enter the /src/ folder. `cd src`
2. Build with the appropriate testing parameters.
    * `make all`: Simulation will run both corner cases and generalized random cases.
    * `make cornercases`: Simulation will run only corner case testing
    * `make randcases`: Simulation will run only random testing
    * `make debug`: Simulation will run both testing cases, and produce output on all test cases.
3. Start simulation with appropriate simulation parameters.
    * `make sim_add`: Run simulation only with addition operations.
    * `make sim_sub`: Run simulation only with subtraction operations.
    * `make sim_mul`: Run simulation only with multiplication operations.
    * `make sim_div`: Run simulation only with division operations.
    * `make sim_all`: Run simulation test cases with ALL operations.
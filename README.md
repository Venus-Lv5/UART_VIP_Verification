# UART IP verification by using UVM
## Introduce
My name is Vo Quang Huy, and I am a course participant at **ICTC (IC Training Center)**. This project is a final coursework at ICTC, developed to create a UVM-based verification environment for a **UART IP**. 

This repository contains the design verification environment and testbench for a Universal Asynchronous Receiver/Transmitter (UART) IP core. The verification is developed using Universal Verification Methodology (UVM) and targets key functional aspects of the UART IP, including data transmission, reception, FIFO behavior, and error handling.

## Input Documents
For further details, please refer to the full documents linked below:
- [UART IP Specification Document](https://github.com/Venus-Lv5/UART_VIP_Verification/blob/1677d8fbe98fa5725d53a0b3cfafe085d81dcc94/docs/UART%20IP%20Specification%20Version%202.0.pdf).

## Tools and Methodology Used
- Languages: SystemVerilog for build environment and create testbenches and verification components.
- Methodology: UVM
- EDA Tool: QuestaSim for simulation and debugging.

## Project Structure
The repository is organized into the following directories:

- `rtl/` - UART IP RTL source code. (provided by ICTC)
- `vip/`
  - `uart_vip/` - UART VIP simulating UART transaction.
  - `ahb_vip/` - AHB VIP simulating AHB master transactions.
- `regmodel/` - UVM register model for UART registers.
- `tb/` - UVM testbench components including environment, scoreboard, testbench.
- `sequences/` - Sequences to generate UART or AHB transactions.
- `testcases/` - Testcases to verify various functionalities.
- `sim/` - Simulation scripts and Makefile
- `docs/` - VPlan and input documents

## Testbench Structure
Below is my Testbench structure to verify the UART IP.
![Testbench structure to verify the VIP](https://github.com/Venus-Lv5/UART_VIP_Verification/blob/1677d8fbe98fa5725d53a0b3cfafe085d81dcc94/docs/tb_structure.png)

**Components:**
- **uart_config**: Contains configuration information for uart_vip and ahb_vip such as baud rate, data width, parity type, stop bits, oversampling, etc.
- **uart_vip**: Simulates transmission and reception data from another UART
- **AHB VIP (Master):** Sends AHB bus transactions to control dut.
- **uart_reg_block**: Manages the registers of the UART IP and handles register read and write operations
- **Adapter**: Translates register-level operations from the UVM register model into UART-specific transactions for the driver to execute.
- **Predictor**: Monitors UART transactions and updates the UVM register model to reflect the expected internal state of the DUT.
- **Scoreboard**: Collects transactions from ahb_monitor and uart_monitor and compares the expected results with the actual outputs from the DUT to ensure functional correctness.
- **Environment**: consists of multiple all verification blocks

## Verification Plan
You can find the full verification strategy and test details and testbench structure in the VPlan:  
- [Verification Plan](https://github.com/Venus-Lv5/UART_VIP_Verification/blob/1677d8fbe98fa5725d53a0b3cfafe085d81dcc94/docs/Vplan_QuangHuy_Final_Prj.csv).

## How to use
- Go to `sim\`
- Run source `project_env.bash` to set up the environment.
- Use `make build` to compile the design.
- Use `make help` to see available commands and usage instructions.

## Result
- Open `sim/regress.rpt` to check the results of the testcases.
- Open `sim/log/` to check the individual logs for each testcase.
- Open `IP_MERGE.ucdb` with QuestaSim to check the coverage results.

## Conclusion
This project is one of my first complete works in the field of Design Verification. It reflects the knowledge and hands-on experience I have gained during my time training at ICTC. The goal of this project is to showcase the knowledge and experience I have gained during my training at ICTC, and to demonstrate my capabilities to future employers. As this is my first complete project, there may still be mistakes — any feedback or suggestions for improvement would be greatly appreciated.

Thank you very much

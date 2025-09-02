## FemRV32: RV32I RISC-V CPU on FPGA

**Short description**: A minimal RV32I RISC-V 5‑stage pipelined CPU implemented in Verilog, with hazard detection, forwarding, branch handling, on-chip instruction/data memory, and testbench for simulation in Xilinx Vivado (XSim).

### Features

- **ISA**: RV32I base integer instruction set
- **Pipeline**: 5 stages with hazard detection and forwarding
- **Modules**: ALU, shifter, control and branch decoders, register file, instruction/data memory
- **Simulation**: XSim scripts and a simple `CPU_tb` testbench
- **Program generation**: Python script to produce random RV32I programs and byte-addressable binaries

### Repository layout

- `ArchProject/` — Vivado project and sources
  - `ArchProject.srcs/sources_1/` — Verilog RTL and testbench
    - `RISCV_Pipeline.v` — top CPU pipeline
    - `final_top.v` — synthesizable top wrapper
    - `RegisterFile.v`, `prv32_ALU.v`, `shifter.v`, `ALUCU.v`, `branchDecoder.v`, `controlUnit.v`, `prv32_imm.v`
    - `DataMem.v`, `InstMem.v`, `singleMemory.v`
    - `forwarding_unit.v`, `hazard_detection_unit.v`
    - `CPU_tb.v` — testbench
  - `ArchProject.sim/` — Vivado simulation artifacts (logs, waves, scripts)
- `Instruction_generator.py` — generates random RV32I programs and byte-encoded binaries
- `Test_cases/` — example outputs and documentation
- `Journal/` — development notes
- `Report.docx` — project report

### Getting started

Prerequisites:

- Xilinx Vivado (tested with XSim)
- Python 3.8+

Clone and open the Vivado project:

1. Open Vivado and use File > Open Project to load `ArchProject/ArchProject.xpr`.
2. Verify the sources under `ArchProject.srcs/sources_1/` are present.

Run simulation (XSim):

1. In Vivado, set `CPU_tb` as the simulation top if not already.
2. Run behavioral simulation. Waveforms (`.wdb`) and logs will be generated under `ArchProject.sim/.../xsim/`.

Synthesis/Implementation on FPGA:

1. Use `final_top.v` as the top module.
2. Add/adjust constraints for your specific board (XDC not included here).
3. Run Synthesis and Implementation, then Generate Bitstream.

### Program generation (Python)

The `Instruction_generator.py` script creates a large random RV32I program and a byte-addressable binary (`program.bin.txt`) suitable for loading into the instruction memory model.

Run:

```bash
python Instruction_generator.py
```

Outputs in the repository root:

- `program.txt` — human-readable assembly-like listing
- `program.bin.txt` — one byte per line, little-endian per 32-bit instruction

You can adapt `InstMem.v` to initialize from these bytes (e.g., `$readmemb`).

### Naming notes

- The testbench file was renamed to `CPU_tb.v` for clarity.
- The synthesizable top remains `final_top.v`.

### Contributing

Issues and pull requests are welcome. Please run simulations and include brief reproduction steps in any bug report.

### License

If you have a preferred license, add a `LICENSE` file (e.g., MIT). Otherwise, all rights reserved by default.

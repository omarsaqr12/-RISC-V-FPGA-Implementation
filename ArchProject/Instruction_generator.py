import random

registers = [f"x{i}" for i in range(32)]
formats = {
    "R": ["ADD", "SUB", "SLL", "SLT", "SLTU", "XOR", "SRL", "SRA", "OR", "AND"],
    "I": ["ADDI", "SLTI", "SLTIU", "XORI", "ORI", "ANDI", "JALR"],
    "shift_I": ["SLLI", "SRLI", "SRAI"],
    "load": ["LB", "LH", "LW", "LBU", "LHU"],
    "S": ["SB", "SH", "SW"],
    "B": ["BEQ", "BNE", "BLT", "BGE", "BLTU", "BGEU"],
    "U": ["LUI", "AUIPC"],
    "J": ["JAL"]
}#excluded the halting instructions from here to aboid early termination of the programm

# Instruction encodings dictionary, extracted from the table in presentation-2
instruction_encodings = {
    "ADD": {"opcode": "0110011", "funct3": "000", "funct7": "0000000"},
    "SUB": {"opcode": "0110011", "funct3": "000", "funct7": "0100000"},
    "SLL": {"opcode": "0110011", "funct3": "001", "funct7": "0000000"},
    "SLT": {"opcode": "0110011", "funct3": "010", "funct7": "0000000"},
    "SLTU": {"opcode": "0110011", "funct3": "011", "funct7": "0000000"},
    "XOR": {"opcode": "0110011", "funct3": "100", "funct7": "0000000"},
    "SRL": {"opcode": "0110011", "funct3": "101", "funct7": "0000000"},
    "SRA": {"opcode": "0110011", "funct3": "101", "funct7": "0100000"},
    "OR": {"opcode": "0110011", "funct3": "110", "funct7": "0000000"},
    "AND": {"opcode": "0110011", "funct3": "111", "funct7": "0000000"},
    "ADDI": {"opcode": "0010011", "funct3": "000"},
    "SLTI": {"opcode": "0010011", "funct3": "010"},
    "SLTIU": {"opcode": "0010011", "funct3": "011"},
    "XORI": {"opcode": "0010011", "funct3": "100"},
    "ORI": {"opcode": "0010011", "funct3": "110"},
    "ANDI": {"opcode": "0010011", "funct3": "111"},
    "JALR": {"opcode": "1100111", "funct3": "000"},
    "SLLI": {"opcode": "0010011", "funct3": "001", "imm_upper": "0000000"},
    "SRLI": {"opcode": "0010011", "funct3": "101", "imm_upper": "0000000"},
    "SRAI": {"opcode": "0010011", "funct3": "101", "imm_upper": "0100000"},
    "LB": {"opcode": "0000011", "funct3": "000"},
    "LH": {"opcode": "0000011", "funct3": "001"},
    "LW": {"opcode": "0000011", "funct3": "010"},
    "LBU": {"opcode": "0000011", "funct3": "100"},
    "LHU": {"opcode": "0000011", "funct3": "101"},
    "SB": {"opcode": "0100011", "funct3": "000"},
    "SH": {"opcode": "0100011", "funct3": "001"},
    "SW": {"opcode": "0100011", "funct3": "010"},
    "BEQ": {"opcode": "1100011", "funct3": "000"},
    "BNE": {"opcode": "1100011", "funct3": "001"},
    "BLT": {"opcode": "1100011", "funct3": "100"},
    "BGE": {"opcode": "1100011", "funct3": "101"},
    "BLTU": {"opcode": "1100011", "funct3": "110"},
    "BGEU": {"opcode": "1100011", "funct3": "111"},
    "LUI": {"opcode": "0110111"},
    "AUIPC": {"opcode": "0010111"},
    "JAL": {"opcode": "1101111"}
}

#  register number to 5-bit binary
def binaryRepresentationOfRegsiters(reg):
    num = int(reg[1:])
    return f"{num:05b}"

# Function to encode instruction to 32-bit binary
def encode_inst(fmt, components, label_to_index, current_index):
    # {inst} {rd}, {rs1}, {rs2}", {"inst": inst, "rd": rd, "rs1": rs1, "rs2": rs2} this is the structure of components
    inst = components["inst"]
    encoding = instruction_encodings[inst]
    opcode = encoding["opcode"]

    if fmt == "R":
        rd = binaryRepresentationOfRegsiters(components["rd"])
        rs1 = binaryRepresentationOfRegsiters(components["rs1"])
        rs2 = binaryRepresentationOfRegsiters(components["rs2"])
        funct3 = encoding["funct3"]
        funct7 = encoding["funct7"]
        return funct7 + rs2 + rs1 + funct3 + rd + opcode

    elif fmt == "I":
        rd = binaryRepresentationOfRegsiters(components["rd"])
        rs1 = binaryRepresentationOfRegsiters(components["rs1"])
        imm = components["imm"]
        imm_bin = bin((imm & 0xFFF) if imm >= 0 else (1 << 12) + imm)[2:].zfill(12)#imm & 0xFFF,ensures that only the least significant 12 bits of imm are kept, not really needed here because of the specified range above, the seocnd part creates 2's compliment
        funct3 = encoding["funct3"]
        return imm_bin + rs1 + funct3 + rd + opcode

    elif fmt == "shift_I":
        rd = binaryRepresentationOfRegsiters(components["rd"])
        rs1 = binaryRepresentationOfRegsiters(components["rs1"])
        shamt = components["shamt"]#shift amount
        shamt_bin = bin(shamt & 0x1F)[2:].zfill(5)
        imm_upper = encoding["imm_upper"]
        imm_bin = imm_upper + shamt_bin
        funct3 = encoding["funct3"]
        return imm_bin + rs1 + funct3 + rd + opcode

    elif fmt == "load":
        rd = binaryRepresentationOfRegsiters(components["rd"])
        rs1 = binaryRepresentationOfRegsiters(components["rs1"])
        imm = components["imm"]
        imm_bin = bin(imm & 0xFFF)[2:].zfill(12) if imm >= 0 else bin(imm & 0xFFF)[2:].zfill(12)#imm & 0xFFF,ensures that only the least significant 12 bits of imm are kept, not really needed here because of the specified range above, the seocnd part creates 2's compliment
        funct3 = encoding["funct3"]
        return imm_bin + rs1 + funct3 + rd + opcode

    elif fmt == "S":
        rs2 = binaryRepresentationOfRegsiters(components["rs2"])
        rs1 = binaryRepresentationOfRegsiters(components["rs1"])
        imm = components["imm"]
        imm_bin = bin(imm & 0xFFF)[2:].zfill(12) if imm >= 0 else bin(imm & 0xFFF)[2:].zfill(12)#imm & 0xFFF,ensures that only the least significant 12 bits of imm are kept, not really needed here because of the specified range above, the seocnd part creates 2's compliment
        funct3 = encoding["funct3"]
        return imm_bin[0:7] + rs2 + rs1 + funct3 + imm_bin[7:12] + opcode

    elif fmt == "B":
        rs1 = binaryRepresentationOfRegsiters(components["rs1"])
        rs2 = binaryRepresentationOfRegsiters(components["rs2"])
        label = components["label"]
        target_index = label_to_index[label]
        offset = (target_index - current_index) * 4
        offset_bin = bin(offset & 0x1FFF)[2:].zfill(13) if offset >= 0 else bin((1 << 13) + offset)[2:].zfill(13)
        imm12 = offset_bin[0]
        imm11 = offset_bin[1]
        imm10_5 = offset_bin[2:8]
        imm4_1 = offset_bin[8:12]
        funct3 = encoding["funct3"]
        return imm12 + imm10_5 + rs2 + rs1 + funct3 + imm4_1 + imm11 + opcode

    elif fmt == "U":
        rd = binaryRepresentationOfRegsiters(components["rd"])
        imm = components["imm"]
        imm_bin = bin(imm & 0xFFFFF)[2:].zfill(20)
        return imm_bin + rd + opcode

    elif fmt == "J":
        rd = binaryRepresentationOfRegsiters(components["rd"])
        label = components["label"]
        target_index = label_to_index[label]
        offset = (target_index - current_index) * 4
        offset_bin = bin(offset & 0x1FFFFF)[2:].zfill(21) if offset >= 0 else bin((1 << 21) + offset)[2:].zfill(21)
        imm20 = offset_bin[0]
        imm10_1 = offset_bin[10:20]
        imm11 = offset_bin[9]
        imm19_12 = offset_bin[1:9]
        return imm20 + imm10_1 + imm11 + imm19_12 + rd + opcode

    else:
        raise ValueError(f"Unknown format: {fmt}")
    
#function to generate  instructions
def generate_inst(inst, fmt, labels):
    rd, rs1, rs2 = [random.choice(registers) for _ in range(3)]# we didn't restrict x0 from benig a destination because our program can inherently handle it
    # the ranges were restricted to make the tests easier to verify, and to avoid handling possible negative pcs
    if fmt == "R":
        return f"{inst} {rd}, {rs1}, {rs2}", {"inst": inst, "rd": rd, "rs1": rs1, "rs2": rs2}
    if fmt == "I":
        imm = random.randint(0, 10)*4# to make sure pc is divisble by 4
        return f"{inst} {rd}, {rs1}, {imm}", {"inst": inst, "rd": rd, "rs1": rs1, "imm": imm}
    if fmt == "shift_I":
        shamt = random.randint(0, 31)
        return f"{inst} {rd}, {rs1}, {shamt}", {"inst": inst, "rd": rd, "rs1": rs1, "shamt": shamt}
    if fmt == "load":
        imm = random.randint(0, 10)
        return f"{inst} {rd}, {imm}({rs1})", {"inst": inst, "rd": rd, "imm": imm, "rs1": rs1}
    if fmt == "S":
        imm = random.randint(0, 10)
        return f"{inst} {rs2}, {imm}({rs1})", {"inst": inst, "rs2": rs2, "imm": imm, "rs1": rs1}
    if fmt == "B":
        label = random.choice(labels)
        return f"{inst} {rs1}, {rs2}, {label}", {"inst": inst, "rs1": rs1, "rs2": rs2, "label": label}
    if fmt == "U":
        imm = random.randint(0, 30)
        return f"{inst} {rd}, {imm}", {"inst": inst, "rd": rd, "imm": imm}
    if fmt == "J":
        label = random.choice(labels)
        return f"{inst} {rd}, {label}", {"inst": inst, "rd": rd, "label": label}
    raise ValueError(f"Unknown format: {fmt}")

# Parameters
N, M = 10000000, 1000000# N:represents the total number of instructions, M represents the number of labels (branch/jump targets), we needed to calculate in advance to be able to  find correct offset to reach the label
labels = [f"L{i}" for i in range(M)]
label_positions = sorted(random.sample(range(N), M))# again we do this to be able to find offest to reach a label
all_insts = [(inst, fmt) for fmt, insts in formats.items() for inst in insts]

# Generate program and collect instructions for encoding
program = ["test generated for  (RV32I)", "limited to  37 instructions, excluding ECALL, EBREAK, PAUSE, FENCE, and FENCE.TSO"]
instructions = []
label_to_index = {labels[m]: label_positions[m] for m in range(M)}
label_idx = 0
inst_index = 0

for i in range(N):# we generate the instructions
    if label_idx < M and i == label_positions[label_idx]:
        program.append(f"{labels[label_idx]}:")
        label_idx += 1
    inst, fmt = random.choice(all_insts)
    assembly, components = generate_inst(inst, fmt, labels)
    program.append(f"\t{assembly}")
    instructions.append((fmt, components, inst_index))
    inst_index += 1

program.append("\t# End of program")

# Save the instructions (worded)
with open("program.txt", "w") as f:
    f.write("\n".join(program))

# (save in byte addresable format)
with open("program.bin.txt", "w") as f:
    binary_encodings = []
    for fmt, components, current_index in instructions:
        binary_str = encode_inst(fmt, components, label_to_index, current_index)
        binary_encodings.append(binary_str)
    
    # divide each 32 bit instruction four 8-bit segments(bytes)
    formatted_encodings = []
    for i, binary_str in enumerate(binary_encodings):
        # Split into four 8-bit chunks
        bytes = [binary_str[j:j+8] for j in range(0, 32, 8)]
        # Revreerse the order of the chunks, to make it compatible with the way we input data in the verilog implementation
        bytes = bytes[::-1]
        for byte in bytes:
            formatted_encodings.append(f"{byte}")
    
    f.write("\n".join(formatted_encodings))
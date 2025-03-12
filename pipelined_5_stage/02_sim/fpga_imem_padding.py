# Define file names
input_file    = "instruction_mem.mem"
output_file_1 = "instruction_mem_padded.mem"
output_file_2 = "../../quartus/pipelined_two_bit/01_imemdata/instruction_mem_padded.mem"

# Define constants
TOTAL_LINES = 8192
PAD_VALUE = "00000000"

try:
    # Read input file and ignore the address marker (@00000000)
    with open(input_file, "r") as f:
        lines = f.readlines()[1:]  # Skip the first line

    # Extract hex data and remove spaces/newlines
    hex_values = "".join(lines).split()

    # Convert to little-endian 4-byte words
    formatted_data = []
    for i in range(0, len(hex_values), 4):
        chunk = hex_values[i:i+4]
        if len(chunk) == 4:
            little_endian_word = "".join(chunk[::-1])  # Reverse bytes
            formatted_data.append(little_endian_word.upper())

    # Pad the file to 8192 lines
    while len(formatted_data) < TOTAL_LINES:
        formatted_data.append(PAD_VALUE)

    # Write to output files
    with open(output_file_1, "w") as f:
        f.write("\n".join(formatted_data) + "\n")
    with open(output_file_2, "w") as f:
        f.write("\n".join(formatted_data) + "\n")

    print(f"FPGA imem file generation completed.")

except FileNotFoundError:
    print(f"Error: File {input_file} not found!")
except Exception as e:
    print(f"An error occurred: {e}")

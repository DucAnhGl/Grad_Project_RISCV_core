def calculate_checksum(record):
    """Calculate the checksum for a given Intel HEX record."""
    total = sum(record) & 0xFF
    checksum = (-total) & 0xFF
    return checksum

def mem_to_intel_hex(input_file, output_file):
    """Convert a .mem file into Intel HEX format with 1-byte records."""
    with open(input_file, 'r') as f:
        # Read all lines from the .mem file
        data = f.read().splitlines()

    # Convert the data to integers
    memory_data = [int(byte, 16) for byte in data]

    # Initialize address and records list
    address = 0
    records = []

    # Convert the memory data to Intel HEX format (1-byte per record)
    for byte in memory_data:
        # Record structure: [byte_count, address_high, address_low, type] + data bytes
        byte_count = 1  # Each record has only 1 byte of data
        record = [byte_count, (address >> 8) & 0xFF, address & 0xFF, 0x00, byte]
        
        # Calculate checksum for the record
        checksum = calculate_checksum(record)
        record.append(checksum)
        
        # Convert the record list to a hex string (starting with ":")
        hex_record = ":" + ''.join(f'{x:02X}' for x in record)
        records.append(hex_record)
        
        # Update address for the next byte
        address += 1

    # Add the end-of-file marker (Intel HEX requires this to be :00000001FF)
    eof_marker = ":00000001FF"
    records.append(eof_marker)

    # Write all the records to the output file
    with open(output_file, 'w') as f:
        f.write('\n'.join(records))  # Join the records with newline and write to the file

    print(f"Conversion complete. Output written to {output_file}")

# Example usage
if __name__ == '__main__':
    input_file_0  = 'dmem/ram0.mem'  # Input .mem file containing memory data (one byte per line)
    output_file_0 = 'dmem/ram0_intel.hex'  # Output .hex file for Intel HEX format
    input_file_1  = 'dmem/ram1.mem'  # Input .mem file containing memory data (one byte per line)
    output_file_1 = 'dmem/ram1_intel.hex'  # Output .hex file for Intel HEX format
    input_file_2  = 'dmem/ram2.mem'  # Input .mem file containing memory data (one byte per line)
    output_file_2 = 'dmem/ram2_intel.hex'  # Output .hex file for Intel HEX format
    input_file_3  = 'dmem/ram3.mem'  # Input .mem file containing memory data (one byte per line)
    output_file_3 = 'dmem/ram3_intel.hex'  # Output .hex file for Intel HEX format

    mem_to_intel_hex(input_file_0, output_file_0)
    mem_to_intel_hex(input_file_1, output_file_1)
    mem_to_intel_hex(input_file_2, output_file_2)
    mem_to_intel_hex(input_file_3, output_file_3)

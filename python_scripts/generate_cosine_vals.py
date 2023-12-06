import numpy as np

def float_to_fixed_point(num):
    # Constants for the number of bits
    INTEGER_BITS = 1
    FRACTIONAL_BITS = 8
    TOTAL_BITS = INTEGER_BITS + FRACTIONAL_BITS

    # Handle the absolute value of the number
    abs_num = abs(num)
    integer_part = int(abs_num)
    fractional_part = abs_num - integer_part

    # Convert the integer part to binary
    integer_binary = format(integer_part, '01b')

    # Round and convert the fractional part to binary
    fractional_binary = format(round(fractional_part * (1 << FRACTIONAL_BITS)), '08b')

    # Combine the two binary parts
    binary_representation = integer_binary + fractional_binary

    # If the number is negative, convert to two's complement
    if num < 0:
        # Convert to unsigned int, invert all bits, add one, and format back to binary
        unsigned_representation = int(binary_representation, 2)
        twos_complement_binary = format(((~unsigned_representation + 1) % (1 << TOTAL_BITS)), f'0{TOTAL_BITS}b')
        binary_representation = twos_complement_binary

    # Convert binary representation back to fixed-point number for comparison
    fixed_point_value = int(binary_representation, 2)
    if num < 0 and fixed_point_value != 0:
        fixed_point_value = fixed_point_value - (1 << TOTAL_BITS)
    fixed_point_value = fixed_point_value / (1 << FRACTIONAL_BITS)

    # Print the original floating point and the calculated fixed-point value
    print(f"Original floating-point value: {num}")
    print(f"Fixed-point value: {fixed_point_value}")
    print(f"Binary representation: {binary_representation}\n")

    return fixed_point_value, binary_representation

cosine_vals_float = np.zeros((8, 8))

filename = "../memfiles/cosine_vals.mem"

with open(filename, 'w') as file:
    for i in range(8):
        binary_row = []
        for j in range(8):
            cosine_vals_float[i][j] = np.cos((2 * i + 1) * j * np.pi / (2 * 8))
            fixed, representation = float_to_fixed_point(cosine_vals_float[i][j])
            binary_row.append(representation)
        # Write the row to the file
        file.write('\t'.join(binary_row) + '\n')


        


import math
import numpy as np

def ndarray_to_mem(array, filename, form='08x'):
    with open(filename, 'w') as file:
        for i in range(array.shape[0]):
            row = []
            for j in range(array.shape[1]):
                string = format(array[i][j], form)
                row.append(string)
            file.write('\t'.join(row) + '\n')

def mem_to_ndarray(file_path, fractional_bits, rows, cols):
    """
    Parses a .mem file and converts hexadecimal values to signed decimal values.

    Args:
    - file_path (str): Path to the .mem file
    - fractional_bits (int): Number of fractional bits for fixed point representation

    Returns:
    - numpy.ndarray: 2D numpy array with 8 rows and 8 columns containing signed decimal values
    """

    # Initialize an empty list to store the decimal values
    decimal_values = []

    # Open and read the file
    with open(file_path, 'r') as file:
        for line in file:
            # Each line is a hexadecimal value
            hex_value = line.strip()

            # Convert hexadecimal to signed integer (52 bits)
            # The mask is for 52 bits
            mask = 0xFFFFFFFFFFFFF
            int_value = int(hex_value, 16)
            if int_value & (1 << 51):  # if the sign bit (52nd bit) is set
                int_value = -((~int_value + 1) & mask)  # two's complement

            # Convert to fixed point representation
            decimal_value = int_value / (2 ** fractional_bits)
            decimal_values.append(decimal_value)

    # Convert the list to a 2D numpy array with 8 rows and 8 columns
    decimal_array = np.array(decimal_values).reshape(rows, cols)

    return decimal_array

def float_to_fixed_point(num, integer_bits, fractional_bits):
    # Total number of bits (integer + fractional)
    total_bits = integer_bits + fractional_bits

    # Handle the absolute value of the number
    abs_num = abs(num)
    integer_part = int(abs_num)
    fractional_part = abs_num - integer_part

    # Format strings for binary conversion
    integer_format_str = f'0{integer_bits}b'
    fractional_format_str = f'0{fractional_bits}b'

    # Convert the integer part to binary
    integer_binary = format(integer_part, integer_format_str)

    # Round and convert the fractional part to binary
    fractional_binary = format(round(fractional_part * (1 << fractional_bits)), fractional_format_str)

    # Combine the two binary parts
    binary_str = integer_binary + fractional_binary

    # If the number is negative, convert to two's complement
    if num < 0:
        # Convert to unsigned int, invert all bits, add one, and format back to binary
        unsigned_representation = int(binary_str, 2)
        twos_complement_binary = format(((~unsigned_representation + 1) % (1 << total_bits)), f'0{total_bits}b')
        binary_str = twos_complement_binary

     # Convert binary representation back to fixed-point number for comparison
    fixed_point_value = int(binary_str, 2)
    if num < 0 and fixed_point_value != 0:
        fixed_point_value = fixed_point_value - (1 << total_bits)
    fixed_point_value = fixed_point_value / (1 << fractional_bits)

    # Print the original floating point and the calculated fixed-point value
    # print(f"Original floating-point value: {num}")
    # print(f"Fixed-point value: {fixed_point_value}")
    # print(f"Binary representation: {binary_str}\n")

    return fixed_point_value, binary_str

def float_arr_to_fixed_arr(float_array, integer_bits, fractional_bits):
    fixed_array = np.zeros_like(float_array)
    for i in range(float_array.shape[0]):
        for j in range(float_array.shape[1]):
            fixed_array[i][j] = float_to_fixed_point(float_array[i][j], integer_bits, fractional_bits)

    return fixed_array

def generate_fixed_cosine_mem(filename, blocksize=8):
    cosine_vals_float = np.zeros((blocksize, blocksize), dtype=float)
    cosine_vals_fixed = np.zeros_like(cosine_vals_float)
    with open(filename, 'w') as file:
        for i in range(blocksize):
            row_str = []
            for j in range(blocksize):
                cosine_vals_float[i][j] = np.cos((2 * i + 1) * j * np.pi / (2 * 8))
                fixed, representation = float_to_fixed_point(cosine_vals_float[i][j], 1, 8)
                cosine_vals_fixed[i][j] = fixed
                row_str.append(representation)
            # Write the row to the file
            file.write('\t'.join(row_str) + '\n')
    return cosine_vals_fixed

def round_matrix(matrix):
    """
    Returns a matrix with all elements rounded to the nearest power of two
    """
    rounded_matrix = np.zeros_like(matrix, dtype=int)
    for i in range(matrix.shape[0]):
        for j in range(matrix.shape[1]):
            n = matrix[i][j]
            if n < 1:
                rounded_matrix[i][j] = 0
            elif n == 1:
                rounded_matrix[i][j] = 1
            else:
                # Find the log base 2 of the number
                log2_n = math.log(n, 2)
                # Round the log2 value to the nearest integer
                nearest_power = round(log2_n)
                # Return 2 raised to the power of the rounded log2 value
                rounded_matrix[i][j] = 2 ** nearest_power

    return rounded_matrix

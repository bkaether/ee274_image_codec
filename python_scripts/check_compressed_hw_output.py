import numpy as np
from dct import *

def parse_mem_file_to_array(file_path, fractional_bits):
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
    decimal_array = np.array(decimal_values).reshape(8, 8)

    return decimal_array

# Example usage
# Note: This function expects a file path to a .mem file, which we cannot create or test in this environment.
# You would need to provide the path to your .mem file when using this function.
# file_path = "path_to_your_file.mem"
# fractional_bits = 16  # Example value for the number of fractional bits
# array = parse_mem_file_to_array(file_path, fractional_bits)
# print(array)

file_path = "../memfiles/hw_output/b1_comp_out_hw.mem"  # Replace with your file path
fractional_bits = 32  # Replace with the number of fractional bits you need
array = parse_mem_file_to_array(file_path, fractional_bits)
np.set_printoptions(suppress=True, precision=4)
print(array)
image = cv2.imread('../image_data/raw/river.jpg', cv2.IMREAD_GRAYSCALE)
python_output = compress_first_block(image)
mse = np.mean((array - python_output) ** 2)
print(mse)
# compressed_block = np.round(array / rounded_quantization_matrix)
# decompressed_block = decompress_block(compressed_block, quantization_matrix)
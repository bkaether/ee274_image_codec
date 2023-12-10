import numpy as np
from utils import *
from codec import *

coeffs_file_path = "../memfiles/hw_output/b1_coeffs_out_hw.mem"
dct_out_file_path = "../memfiles/hw_output/b1_comp_out_hw.mem"
shift_file_path = "../memfiles/quantization.mem"
fractional_bits = 32
first_block_coeffs = mem_to_ndarray(coeffs_file_path, 0, 8, 8)
first_block_dct = mem_to_ndarray(dct_out_file_path, fractional_bits, 8, 8)
shift_values = mem_2d_to_ndarray(shift_file_path, 8, 8)
np.set_printoptions(suppress=True, precision=4)
image = cv2.imread('../image_data/raw/river.jpg', cv2.IMREAD_GRAYSCALE)

quantization_matrix = np.array([[16, 11, 10, 16, 24, 40, 51, 61],
                                [12, 12, 14, 19, 26, 58, 60, 55],
                                [14, 13, 16, 24, 40, 57, 69, 56],
                                [14, 17, 22, 29, 51, 87, 80, 62],
                                [18, 22, 37, 56, 68, 109, 103, 77],
                                [24, 35, 55, 64, 81, 104, 113, 92],
                                [49, 64, 78, 87, 103, 121, 120, 101],
                                [72, 92, 95, 98, 112, 100, 103, 99]])

rounded_quantization_matrix = round_matrix(quantization_matrix)

python_output = compress_block(image[0:8, 0:8], rounded_quantization_matrix)
mse = np.mean((first_block_coeffs - python_output) ** 2)

print("\nRTL First Block DCT Output:\n", first_block_dct)
print("\nRTL shift values:\n", shift_values)
print("\nRTL First Block Coeffs Output:\n", first_block_coeffs)
print("\nPython First Block Output:\n", python_output)

# print(mse)
# compressed_block = np.round(first_block_coeffs / rounded_quantization_matrix)
# decompressed_block = decompress_block(compressed_block, quantization_matrix)
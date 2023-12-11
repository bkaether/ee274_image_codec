import numpy as np
from utils import *
from codec import *

block1_coeffs_file_path = "../memfiles/hw_output/b1_coeffs_out_hw.mem"
full_coeffs_file_path = "../memfiles/hw_output/full_image_comp_out_hw.mem"
# dct_out_file_path = "../memfiles/hw_output/b1_comp_out_hw.mem"
shift_file_path = "../memfiles/quantization.mem"

b1_reconstructed_file_path = "../memfiles/hw_output/b1_reconstructed_out_hw.mem"
full_hw_reconstruction_path = "../memfiles/hw_output/full_image_reconstructed_hw.mem"

first_block_coeffs = mem_to_ndarray(block1_coeffs_file_path, 9, 0, 8, 8)
full_image_coeffs = mem_to_ndarray(full_coeffs_file_path, 9, 0, 480, 640)
# first_block_dct = mem_to_ndarray(dct_out_file_path, 54, 32, 8, 8)
shift_values = mem_2d_to_ndarray(shift_file_path, 8, 8)

first_block_reconstructed = mem_to_ndarray(b1_reconstructed_file_path, 63, 32, 8, 8)
full_image_reconstructed = mem_to_ndarray(full_hw_reconstruction_path, 63, 32, 480, 640)

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

# Uncomment the below code to print out both the python and rtl results for the compressed/decompressed first block

# python_block_compressed = compress_block(image[0:8, 0:8], rounded_quantization_matrix)
# python_block_reconstructed = decompress_block(python_block_compressed, rounded_quantization_matrix)

# print("\nRTL First Block Coeffs Output:\n", first_block_coeffs)
# print("\nPython First Block Coeffs Output:\n", python_block_compressed)

# print("\nRTL First Block Reconstructed Output:\n", first_block_reconstructed)
# print("\nPython First Block Reconstructed Output:\n", python_block_reconstructed)

# decompress rtl coefficients in software to ensure compression correctness
decompressed_image = decompress_image(full_image_coeffs, rounded_quantization_matrix)

# get proper python reconstruction for final rtl comparison
compressed_sw, decompressed_sw = process_image(image, quantization_matrix)

# calculate MSE between python and rtl image reconstruction
mse = np.mean((decompressed_sw - full_image_reconstructed) ** 2)
print("\nMSE Difference Between Python and RTL Reconstruction:\n", mse)

cv2.imwrite('../image_data/decompressed/hw/river.jpg', decompressed_image) # rtl compression -> python decompression image
cv2.imwrite('../image_data/decompressed/hw/river_full_hw.jpg', full_image_reconstructed) # rtl compression -> rtl decompression image
import math
import numpy as np
import cv2
from utils import *

# build quantization matrix
quantization_matrix = np.array([[16, 11, 10, 16, 24, 40, 51, 61],
                                [12, 12, 14, 19, 26, 58, 60, 55],
                                [14, 13, 16, 24, 40, 57, 69, 56],
                                [14, 17, 22, 29, 51, 87, 80, 62],
                                [18, 22, 37, 56, 68, 109, 103, 77],
                                [24, 35, 55, 64, 81, 104, 113, 92],
                                [49, 64, 78, 87, 103, 121, 120, 101],
                                [72, 92, 95, 98, 112, 100, 103, 99]])

rounded_quantization_matrix = round_matrix(quantization_matrix)
quantization_matrix_shits = np.log2(rounded_quantization_matrix).astype(int)

print("Default Quantization Matrix: \n", quantization_matrix)
print("\nRounded to Nearest Power of 2: \n", rounded_quantization_matrix)
print("\nValues to Bit Shift By: \n", quantization_matrix_shits)

# create .mem file with bit shift matrix
quantization_file = "../memfiles/quantization.mem"
ndarray_to_mem(quantization_matrix_shits, quantization_file, form='03b')

# generate cosine values and create .mem file
cosine_file = "../memfiles/cosine_vals.mem"
cosine_vals_fixed = generate_fixed_cosine_mem(cosine_file, blocksize=8)

print("\nFixed Cosine Values:\n", cosine_vals_fixed)

# load image
image = cv2.imread('../image_data/raw/river.jpg', cv2.IMREAD_GRAYSCALE)

# create full image .mem file
full_image_file = "../memfiles/full_image.mem"
ndarray_to_mem(image, full_image_file, '09b')

# create first block mem file for testing
first_block_file = "../memfiles/first_block.mem"
ndarray_to_mem(image[0:8, 0:8], first_block_file, '09b')


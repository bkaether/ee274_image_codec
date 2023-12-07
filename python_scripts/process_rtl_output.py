import numpy as np
from utils import *
from codec import *

file_path = "../memfiles/hw_output/b1_comp_out_hw.mem"
fractional_bits = 32
first_block_coeffs = mem_to_ndarray(file_path, fractional_bits, 8, 8)
np.set_printoptions(suppress=True, precision=4)
print("\nRTL Ouput for Coefficients of the First Image Block:\n", first_block_coeffs)
image = cv2.imread('../image_data/raw/river.jpg', cv2.IMREAD_GRAYSCALE)
python_output = compress_first_block(image)
mse = np.mean((first_block_coeffs - python_output) ** 2)
# print(mse)
# compressed_block = np.round(first_block_coeffs / rounded_quantization_matrix)
# decompressed_block = decompress_block(compressed_block, quantization_matrix)
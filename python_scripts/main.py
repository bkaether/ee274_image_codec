import cv2
import numpy as np
from utils import *
from codec import *

# Load grayscale image
image = cv2.imread('../image_data/raw/river.jpg', cv2.IMREAD_GRAYSCALE)

# build quantization matrix
quantization_matrix = np.array([[16, 11, 10, 16, 24, 40, 51, 61],
                                [12, 12, 14, 19, 26, 58, 60, 55],
                                [14, 13, 16, 24, 40, 57, 69, 56],
                                [14, 17, 22, 29, 51, 87, 80, 62],
                                [18, 22, 37, 56, 68, 109, 103, 77],
                                [24, 35, 55, 64, 81, 104, 113, 92],
                                [49, 64, 78, 87, 103, 121, 120, 101],
                                [72, 92, 95, 98, 112, 100, 103, 99]])

# round quantization matrix
rounded_quantization_matrix = round_matrix(quantization_matrix)

np.set_printoptions(suppress=True, precision=4)
first_dct_block = compress_first_block(image)
print("\nCoefficients for First DCT Block:\n", first_dct_block)

compressed, decompressed = process_image(image, quantization_matrix)

compressed_rounded, decompressed_rounded = process_image(image, rounded_quantization_matrix)

mse = np.mean((image - decompressed) ** 2)
mse_rounded = np.mean((image - decompressed_rounded) ** 2)

# print("\nMSE between raw and reconstructed image with normal matrix:\n", mse)
# print("\nMSE between raw and reconstructed image with rounded matrix:\n", mse_rounded)

# Save or display the decompressed image
cv2.imwrite('../image_data/decompressed/river.jpg', decompressed)
cv2.imwrite('../image_data/decompressed/river_rounded.jpg', decompressed_rounded)
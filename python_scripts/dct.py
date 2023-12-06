import math
import cv2
import numpy as np

def round_quantization_matrix(matrix):
    rounded_matrix = np.zeros_like(matrix, dtype=float)
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

def dct_2d(block):
    N = block.shape[0]
    dct_block = np.zeros_like(block, dtype=float)
    for u in range(N):
        for v in range(N):
            sum = 0
            for x in range(N):
                for y in range(N):
                    sum += block[x, y] * np.cos((2 * x + 1) * u * np.pi / (2 * N)) * np.cos((2 * y + 1) * v * np.pi / (2 * N))
            alpha_u = 1/np.sqrt(N) if u == 0 else np.sqrt(2)/np.sqrt(N)
            alpha_v = 1/np.sqrt(N) if v == 0 else np.sqrt(2)/np.sqrt(N)
            dct_block[u, v] = alpha_u * alpha_v * sum
    return dct_block

def idct_2d(dct_block):
    N = dct_block.shape[0]
    reconstructed_block = np.zeros_like(dct_block, dtype=float)
    for x in range(N):
        for y in range(N):
            sum = 0
            for u in range(N):
                for v in range(N):
                    alpha_u = 1/np.sqrt(N) if u == 0 else np.sqrt(2)/np.sqrt(N)
                    alpha_v = 1/np.sqrt(N) if v == 0 else np.sqrt(2)/np.sqrt(N)
                    sum += alpha_u * alpha_v * dct_block[u, v] * np.cos((2 * x + 1) * u * np.pi / (2 * N)) * np.cos((2 * y + 1) * v * np.pi / (2 * N))
            reconstructed_block[x, y] = sum
    return reconstructed_block

# def dct_2d(block):
#     """Apply 2D DCT to an 8x8 block."""
#     return cv2.dct(block.astype(np.float32))

# def idct_2d(block):
#     """Apply 2D inverse DCT to an 8x8 block."""
#     return cv2.idct(block)

def compress_block(block, quantization_matrix):
    dct_block = dct_2d(block)
    return np.round(dct_block / quantization_matrix)

def decompress_block(block, quantization_matrix):
    dequantized = block * quantization_matrix
    return idct_2d(dequantized)

def process_image(image, quantization_matrix):
    h, w = image.shape
    compressed = np.zeros_like(image, dtype=np.float32)
    decompressed = np.zeros_like(image, dtype=np.uint8)
    for i in range(0, h, 8):
        for j in range(0, w, 8):
            block = image[i:i+8, j:j+8]
            compressed_block = compress_block(block, quantization_matrix)
            decompressed_block = decompress_block(compressed_block, quantization_matrix)
            compressed[i:i+8, j:j+8] = compressed_block
            decompressed[i:i+8, j:j+8] = np.clip(decompressed_block, 0, 255)
    return compressed, decompressed

# Load grayscale image
image = cv2.imread('../image_data/raw/river.jpg', cv2.IMREAD_GRAYSCALE)

# Define a simple quantization matrix
quantization_matrix = np.array([[16, 11, 10, 16, 24, 40, 51, 61],
                                [12, 12, 14, 19, 26, 58, 60, 55],
                                [14, 13, 16, 24, 40, 57, 69, 56],
                                [14, 17, 22, 29, 51, 87, 80, 62],
                                [18, 22, 37, 56, 68, 109, 103, 77],
                                [24, 35, 55, 64, 81, 104, 113, 92],
                                [49, 64, 78, 87, 103, 121, 120, 101],
                                [72, 92, 95, 98, 112, 100, 103, 99]])

rounded_quantization_matrix = round_quantization_matrix(quantization_matrix)
# print(rounded_quantization_matrix)
# print("\nMax Value in Grayscale Image: ", np.max(image))
# print("\nMin Value in Grayscale Image: ", np.min(image))

# compressed, decompressed = process_image(image, quantization_matrix)

compressed_rounded, decompressed_rounded = process_image(image, rounded_quantization_matrix)

# print("\nMax Value in Compressed Image: ", np.max(compressed_rounded))
# print("\nMin Value in Compressed Image: ", np.min(compressed_rounded))

# print("\nMax Value in Decompressed Image: ", np.max(decompressed_rounded))
# print("\nMin Value in Decompressed Image: ", np.min(decompressed_rounded))

# Save or display the decompressed image
cv2.imwrite('../image_data/decompressed/river_rounded.jpg', decompressed_rounded)
# cv2.imshow('Decompressed Image', decompressed)
# cv2.waitKey(0)
# cv2.destroyAllWindows()

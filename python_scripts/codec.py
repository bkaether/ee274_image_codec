import numpy as np
import cv2


# def dct_2d(block):
#     N = block.shape[0]
#     dct_block = np.zeros_like(block, dtype=float)
#     for u in range(N):
#         for v in range(N):
#             sum = 0
#             for x in range(N):
#                 for y in range(N):
#                     sum += block[x, y] * np.cos((2 * x + 1) * u * np.pi / (2 * N)) * np.cos((2 * y + 1) * v * np.pi / (2 * N))
#             alpha_u = 1/np.sqrt(N) if u == 0 else np.sqrt(2)/np.sqrt(N)
#             alpha_v = 1/np.sqrt(N) if v == 0 else np.sqrt(2)/np.sqrt(N)
#             dct_block[u, v] = alpha_u * alpha_v * sum
#     return dct_block

# def idct_2d(dct_block):
#     N = dct_block.shape[0]
#     reconstructed_block = np.zeros_like(dct_block, dtype=float)
#     for x in range(N):
#         for y in range(N):
#             sum = 0
#             for u in range(N):
#                 for v in range(N):
#                     alpha_u = 1/np.sqrt(N) if u == 0 else np.sqrt(2)/np.sqrt(N)
#                     alpha_v = 1/np.sqrt(N) if v == 0 else np.sqrt(2)/np.sqrt(N)
#                     sum += alpha_u * alpha_v * dct_block[u, v] * np.cos((2 * x + 1) * u * np.pi / (2 * N)) * np.cos((2 * y + 1) * v * np.pi / (2 * N))
#             reconstructed_block[x, y] = sum
#     return reconstructed_block

def dct_2d(block):
    """Apply 2D DCT to an 8x8 block."""
    return cv2.dct(block.astype(np.float32))

def idct_2d(block):
    """Apply 2D inverse DCT to an 8x8 block."""
    return cv2.idct(block)

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

def compress_first_block(image):
    block = image[0:8, 0:8]
    dct_block = dct_2d(block)
    return dct_block
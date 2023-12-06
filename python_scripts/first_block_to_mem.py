import cv2
import numpy as np

# Load grayscale image
image = cv2.imread('../image_data/raw/river.jpg', cv2.IMREAD_GRAYSCALE)
first_block = image[0:8, 0:8]
print(first_block)

filename = "../memfiles/first_block.mem"

with open(filename, 'w') as file:
    for i in range(8):
        binary_row = []
        for j in range(8):
            binary_string = format(first_block[i][j], '09b')
            binary_row.append(binary_string)
        # Write the row to the file
        file.write('\t'.join(binary_row) + '\n')
import numpy as np

cosine_vals = np.zeros((8, 8))

for i in range(8):
    for j in range(8):
        cosine_vals[i][j] = np.cos(2 * i + 1) * j * np.pi / (2 * 8)
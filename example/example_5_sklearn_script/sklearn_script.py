import numpy as np
from sklearn.preprocessing import StandardScaler
from lib.process_with_mmap import process_via_mmap

@process_via_mmap
def scale_mmap(input_data):
    scaler = StandardScaler()
    scaled = scaler.fit_transform(input_data.reshape(-1, 1))
    return scaled.flatten()

if __name__ == "__main__":
    scale_mmap()

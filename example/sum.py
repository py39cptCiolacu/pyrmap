import numpy as np
from lib.process_with_mmap import process_via_mmap

@process_via_mmap
def sum_mmap(input_data):
    return np.sum(input_data)

if __name__ == "__main__":
    sum_mmap()

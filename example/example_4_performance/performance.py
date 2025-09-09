import numpy as np
from lib.process_with_mmap import process_via_mmap

@process_via_mmap
def performance(input_data):
    sum = np.sum(input_data)

    return input_data

if __name__ == "__main__":
    performance()

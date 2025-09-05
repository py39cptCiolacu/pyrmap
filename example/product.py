import numpy as np
from lib.process_with_mmap import process_via_mmap

@process_via_mmap
def product_mmap(input_data):
    return np.prod(input_data)

if __name__ == "__main__":
    product_mmap()

import mmap
import struct
import numpy as np
from lib.metadata_manipulation import get_metadata_info, calculate_result_size, write_result_size 

DATA_FILE = "/tmp/data.bin"
RESULT_FILE = "/tmt/result.bin"

def process_via_mmap(func):
    input_size, dtype = get_metadata_info()
    dtype_size = np.dtype(dtype).itemsize

    def wrapper():

        with open(DATA_FILE, "r+b") as f:

            mm = mmap.mmap(f.fileno(), input_size * dtype_size)
            input_data = np.frombuffer(mm.read(dtype_size * input_size), dtype=dtype)
            mm.close()
        
        output_data = func(input_data)

        result_size = calculate_result_size(output_data)
        write_result_size(result_size)
            
        with open(RESULT_FILE, "wb") as f:
            f.write(b"\x00" * (result_size * dtype_size))

        with open(RESULT_FILE, "r+b") as f:
            
            mm = mmap.mmap(f.fileno(), result_size*dtype_size)
            mm.write(output_data.astype(dtype).tobytes())
            mm.close()

    return wrapper

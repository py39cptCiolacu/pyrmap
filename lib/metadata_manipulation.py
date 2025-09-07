import numpy as np
import struct
import mmap

METADATA_FILE = "metadata.bin"
METADATA_FILE_SIZE = 8 + 4 + 4 + 4 #8 for flag, 4 for data size, 4 for dtype, 4 for result size

DTYPE_MAP = {
        1: np.float32,
        2: np.float64,
        3: np.int32,
        4: np.int64,
        5: np.uint8,
}

def get_metadata_info():

    with open(METADATA_FILE, "r+b") as f:
        mm = mmap.mmap(f.fileno(), METADATA_FILE_SIZE)
        mm.seek(8)
        input_data_size = np.frombuffer(mm.read(4), dtype=np.int32)[0]
        dtype_code = np.frombuffer(mm.read(4), dtype=np.int32)[0]
    
        mm.close()
        
        dtype = DTYPE_MAP[dtype_code]

    return input_data_size, dtype


def calculate_result_size(output):
    if np.isscalar(output) or isinstance(output, int):
        return 1
    elif isinstance(output, (list, tuple)):
        return len(output)
    elif isinstance(output, np.ndarray):
        return output.size
    else:
        raise TypeError(f"Unspported output type: {type(output)}")


def write_result_size(result_size):
    with open(METADATA_FILE, "r+b") as f:
        mm = mmap.mmap(f.fileno(), METADATA_FILE_SIZE)
        mm.seek(8+4)
        mm.write(struct.pack("i", result_size))
        mm.seek(0)
        mm.write(struct.pack("Q", 1))
        mm.close()

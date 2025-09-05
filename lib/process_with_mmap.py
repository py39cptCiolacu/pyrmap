import mmap
import struct
import numpy as np

METADATA_FILE = "metadata.bin"
METADATA_FILE_SIZE = 8 + 4 + 4 #8 for flag, 4 for data size, 4 for result size

DATA_FILE = "data.bin"
RESULT_FILE = "result.bin"

def get_input_size():

    with open(METADATA_FILE, "r+b") as f:
        mm = mmap.mmap(f.fileno(), METADATA_FILE_SIZE)
        mm.seek(8)
        input_data_size = np.frombuffer(mm.read(4), dtype=np.int32)[0]
        mm.close()

    return input_data_size

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

def process_via_mmap(func):
    input_size = get_input_size()

    def wrapper():

        with open(DATA_FILE, "r+b") as f:

            mm = mmap.mmap(f.fileno(), input_size * 4)
            input_data = np.frombuffer(mm.read(4 * input_size), dtype=np.float32)
            mm.close()
        
        output_data = func(input_data)

        result_size = calculate_result_size(output_data)
        write_result_size(result_size)
            
        with open(RESULT_FILE, "wb") as f:
            f.write(b"\x00" * (result_size * 4))

        with open(RESULT_FILE, "r+b") as f:
            
            mm = mmap.mmap(f.fileno(), result_size*4)
            mm.write(output_data.astype("float32").tobytes())
            mm.close()

    return wrapper

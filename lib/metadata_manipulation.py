# Copyright 2025 PyRMap contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import numpy as np
import struct
import mmap

METADATA_FILE = "/dev/shm/metadata.bin"
METADATA_FILE_SIZE = 8 + 4 + 4 + 4 + 4 #8 for flag, 4 for data size, 4 for dtype, 4 for path ,4 for result size

DTYPE_MAP = {
        1: np.float32,
        2: np.float64,
        3: np.int32,
        4: np.int64,
        5: np.uint8,
}

PATH_MAP = {
        1: "/dev/shm",
        2: "/home/pyrmap/storage",
}

def get_metadata_info():

    with open(METADATA_FILE, "r+b") as f:
        mm = mmap.mmap(f.fileno(), METADATA_FILE_SIZE)
        mm.seek(4)
        input_data_size = np.frombuffer(mm.read(4), dtype=np.int32)[0]
        dtype_code = np.frombuffer(mm.read(4), dtype=np.int32)[0]
        path_code = np.frombuffer(mm.read(4), dtype=np.int32)[0]
    
        mm.close()
        
        dtype = DTYPE_MAP[dtype_code]
        path = PATH_MAP[path_code]

    return input_data_size, dtype, path


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
        mm.seek(4+4)
        mm.write(struct.pack("i", result_size))
        mm.seek(0)
        mm.write(struct.pack("Q", 1))
        mm.close()

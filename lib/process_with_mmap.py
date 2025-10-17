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

import mmap
import numpy as np
from lib.metadata_manipulation import get_metadata_info, calculate_result_size, write_result_size 

DATA_FILE = "/data.bin"
RESULT_FILE = "/result.bin"

def process_via_mmap(func):
    input_size, dtype, path = get_metadata_info()
    dtype_size = np.dtype(dtype).itemsize

    def wrapper():

        with open(f"{path}{DATA_FILE}", "r+b") as f:

            mm = mmap.mmap(f.fileno(), input_size * dtype_size)
            input_data = np.frombuffer(mm.read(dtype_size * input_size), dtype=dtype)
            mm.close()
        
        output_data = func(input_data)

        result_size = calculate_result_size(output_data)
        write_result_size(result_size)
            
        with open(f"{path}{RESULT_FILE}", "wb") as f:
            f.write(b"\x00" * (result_size * dtype_size))

        with open(f"{path}{RESULT_FILE}", "r+b") as f:
            
            mm = mmap.mmap(f.fileno(), result_size*dtype_size)
            mm.write(output_data.astype(dtype).tobytes())
            mm.close()

    return wrapper

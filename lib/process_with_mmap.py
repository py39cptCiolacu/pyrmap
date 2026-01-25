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
    dtype_np = np.dtype(dtype)
    dtype_size = np.dtype(dtype).itemsize

    def wrapper():

        with open(f"{path}{DATA_FILE}", "r+b") as f:

            mm_in = mmap.mmap(f.fileno(), input_size * dtype_size, access=mmap.ACCESS_READ)
            # input_data = np.frombuffer(mm.read(dtype_size * input_size), dtype=dtype)
            # mm.close()
            input_data = np.ndarray(shape=(input_size, ), dtype=dtype_np, buffer=mm_in)

        output_data = func(input_data)

        result_size = calculate_result_size(output_data)
        write_result_size(result_size)
            
        with open(f"{path}{RESULT_FILE}", "wb") as f:
            f.truncate(result_size * dtype_size)

        with open(f"{path}{RESULT_FILE}", "r+b") as f:
            
            mm_out = mmap.mmap(f.fileno(), result_size*dtype_size, access=mmap.ACCESS_WRITE)
            # mm.write(output_data.astype(dtype).tobytes())
            # mm.close()
            out_view = np.asarray(output_data, dtype=dtype_np)
            mm_out.write(out_view.tobytes())

    return wrapper

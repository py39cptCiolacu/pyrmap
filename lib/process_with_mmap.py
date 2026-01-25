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
    _, dtype, path = get_metadata_info()
    dtype_np = np.dtype(dtype)
    dtype_size = np.dtype(dtype).itemsize

    def wrapper():

        input_data = np.memmap(f"{path}{DATA_FILE}", dtype=dtype_np, mode="r")

        output_data = func(input_data)
        result_size = calculate_result_size(output_data)
        write_result_size(result_size)
            
        with open(f"{path}{RESULT_FILE}", "wb") as f:
            f.truncate(result_size * dtype_size)

        with open(f"{path}{RESULT_FILE}", "r+b") as f:
            
            mm_out = mmap.mmap(f.fileno(), result_size*dtype_size, access=mmap.ACCESS_WRITE)
            out_view = np.asarray(output_data, dtype=dtype_np)
            mm_out.write(out_view.tobytes())


    return wrapper

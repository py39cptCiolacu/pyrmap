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

source("../../lib/file_manipulation.R")
source("../../lib/file_locations.R")

METADATA_FILE <- "/dev/shm/metadata.bin"

run_python <- function(data, python_script_path, dtype="float32", path = "RAM") {

    library(processx)
    input_size <- length(data)
    
    if (path == "DISK") {
        if (!dir.exists("/home/pyrmap")){
            dir.create("/home/pyrmap")
        }

        if (!dir.exists("/home/pyrmap/storage")){
            dir.create("/home/pyrmap/storage")
        }
    }

    # 1 = float32
    # 2 = float64
    # 3 = int32
    # 4 = int64
    # 5 = uint8
    
    metadata_file_cw(input_size, dtype, path)  
    dtype_size <- get_size_per_type(dtype)
    data_file_cw(data, dtype_size*input_size, dtype, path)

    processx::run("python3", args = python_script_path, env=c(SHM_DIR="/dev/shm", Sys.getenv()))
    result = result_file_r(dtype, path)

    cleanup(path)
    return(result)
}

run_python_shared_data <- function(data, python_scripts_paths, dtype="float32", path="RAM") {
    library(processx)
    results <- c()

    RESULT_FILE = get_result_file_path(path)
    
    input_size <- length(data)
    metadata_flag_edit_w(0)
    dtype_size <- get_size_per_type(dtype)
    data_file_cw(data, dtype_size*input_size, dtype, path)
    
    for (python_script_path in python_scripts_paths) {
        processx::run("python3", args = python_script_path)
        
        result <- result_file_r(dtype, path)
        results <- c(results, result)
        file.remove(RESULT_FILE)

        metadata_flag_edit_w(0)
    }

    cleanup(path)
    return(results)
}

run_python_pipeline <- function(initial_data, python_scripts_paths, dtype="float32", path="RAM", required_intermediate_results=FALSE) {
    library(processx)
    initial_input_size <- length(initial_data)

    DATA_FILE = get_data_file_path(path)
    RESULT_FILE = get_result_file_path(path)
    
    dtype_size <- get_size_per_type(dtype)
    metadata_file_cw(initial_input_size, dtype, path)
    data_file_cw(initial_data, dtype_size*initial_input_size, dtype, path)

    if (isTRUE(required_intermediate_results)) {
        results <- c()
    }

    for (python_script_path in python_scripts_paths) {
        processx::run("python3", args = python_script_path)
        result <- result_file_r(dtype, path)
        
        if (isTRUE(required_intermediate_results)) {
            results <- c(results, result)
        }

        file.remove(METADATA_FILE)
        
        temp_data_file_size <- length(result)
        metadata_file_cw(temp_data_file_size, dtype, path)
        file.rename(RESULT_FILE, DATA_FILE)
    }
    
    cleanup(path)

    if (isTRUE(required_intermediate_results)) {
        return(results)
    }

    return(result)
}

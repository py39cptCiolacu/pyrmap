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

source("../../lib/file_locations.R")

METADATA_FILE <- "/dev/shm/metadata.bin"
METADATA_FILE_SIZE <- 8 + 4 + 4 + 4 + 4

library(mmap)
# c - create
# r - read
# w - write
# d - delete

dtype_dict <- c(
    "float32" = 1,
    "float64" = 2,
    "int32" = 3,
    "int64" = 4,
    "uint8" = 5
)

get_size_per_type <-function(dtype) {

    if (endsWith(dtype, "32")) return(4)
    if (endsWith(dtype, "64")) return(8)
    if (endsWith(dtype, "8")) return(1)
    stop("Given type is not valid!")
}

get_mmap_mode_per_type <- function(dtype){
    if (dtype == "int32") {return(int32())}
    if (dtype == "int64") {return(int64())}
    if (dtype == "float32") {return(single())}
    if (dtype == "float64") {return(double())}
    if (dtype == "uint8") {return(uint8())}
}

metadata_file_cw <- function(input_size, dtype, path) {

    con <- file(METADATA_FILE, "wb")
    writeBin(rep(as.raw(0), METADATA_FILE_SIZE), con)
    close(con)
        
    m <- mmap(METADATA_FILE, mode=int32(), prot = mmapFlags("PROT_READ", "PROT_WRITE"))
    if (is.null(m)) stop("Failed to mmap the metadata_file")
    
    if (path == "RAM") {
        location_flag <- 1
    }
    
    if (path == "DISK") {
        location_flag <- 2
    }

    m[1] <- 0                      # flag
    m[2] <- input_size             # input_size
    m[3] <- dtype_dict[[dtype]]    # dtype
    m[4] <- location_flag          # location flag: 1 RAM ; 2 - DISK
    m[5] <- 0                      # result_size (for now 0 - will be calculed and overwriten in python)

    #flush(m)
    munmap(m)
   
}

metadata_flag_edit_w <- function(new_flag_value) {
    m <- mmap(METADATA_FILE, mode=int32(), prot = mmapFlags("PROT_WRITE"))
    m[1] <- new_flag_value
    munmap(m)
}

data_file_cw <- function(data, data_file_size, dtype, path) {
    
    DATA_FILE <- get_data_file_path(path)

    # data_file_size - should be already calculated by multiplying len(data) with dtype_size
    dtype_size <- get_size_per_type(dtype)

    con <- file(DATA_FILE, "wb")
    writeBin(rep(as.raw(0), data_file_size), con)
    close(con)
    
    dtype_mmap_mode = get_mmap_mode_per_type(dtype)
    m <- mmap(DATA_FILE, mode=dtype_mmap_mode, prot = mmapFlags("PROT_READ", "PROT_WRITE"))

    if (grepl("^int", dtype)){
        m[] <- as.integer(data)
    }
    else if (grepl("^float", dtype)){
        m[] <- as.numeric(data)
    }
    else if (grepl("^uint", dtype)){
        m[] <- as.raw(data)
    }
    else{
        stop("Given type is not valid!")
    }
    
    #flush(m)
    munmap(m)
}

get_result_file_size <- function(path) {
    
    m <- mmap(METADATA_FILE, mode=int32(), prot = mmapFlags("PROT_READ"))
    
    metadata_flag <- m[1]
    if (metadata_flag != 1) stop("Python didn't write result size")

    result_size <- m[4]
    munmap(m)
    return(result_size)

}

result_file_r <- function(dtype, path) {
    
    RESULT_FILE <- get_result_file_path(path)
    
    result_size <- get_result_file_size(path)
    dtype_size <- get_size_per_type(dtype)
    dtype_mmap_mode = get_mmap_mode_per_type(dtype)

    m <- mmap(RESULT_FILE, mode=dtype_mmap_mode, prot = mmapFlags("PROT_READ"))
    result <- m[]
    munmap(m)

    return(result)
}

cleanup <- function(path) {
    
    DATA_FILE <- get_data_file_path(path)
    RESULT_FILE <- get_result_file_path(path)

    files <- c(DATA_FILE, METADATA_FILE, RESULT_FILE)
    for (f in files) if (file.exists(f)) file.remove(f)
}


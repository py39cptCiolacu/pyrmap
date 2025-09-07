source("/home/shared_memory/pyrmap/lib/file_manipulation.R")

DATA_FILE <- "data.bin"
RESULT_FILE <- "result.bin"
METADATA_FILE <- "metadata.bin"

run_python <- function(data, python_script_path, dtype=1) {

    library(processx)
    input_size <- length(data)
    
    # 1 = float32
    # 2 = float64
    # 3 = int32
    # 4 = int64
    # 5 = uint8
    
    metadata_file_cw(input_size, dtype)  
    dtype_size <- get_size_per_type(dtype)
    data_file_cw(data, dtype_size*input_size, dtype)

    processx::run("python3", args = python_script_path)
    result = result_file_r(dtype, dtype_size)

    cleanup()
    return(result)
}

run_python_shared_data <- function(data, python_scripts_paths, dtype=1) {
    library(processx)
    results <- c()

    input_size <- length(data)
    metadata_file_cw(input_size, dtype) #change this to a flag change only
    dtype_size <- get_size_per_type(dtype)
    data_file_cw(data, dtype_size*input_size, dtype)
    
    for (python_script_path in python_scripts_paths) {
        processx::run("python3", args = python_script_path)
        
        result <- result_file_r(dtype, dtype_size)
        results <- c(results, result)
        file.remove(RESULT_FILE)

        metadata_file_cw(input_size, dtype) #change this to a flag change only
    }

    cleanup()
    return(results)
}

run_python_pipeline <- function(initial_data, python_scripts_paths, dtype=1) {
    library(processx)
    initial_input_size <- length(initial_data)

    dtype_size <- get_size_per_type(dtype)
    metadata_file_cw(initial_input_size, dtype)
    data_file_cw(initial_data, dtype_size*initial_input_size, dtype)

    for (python_script_path in python_scripts_paths) {
        processx::run("python3", args = python_script_path)
        result <- result_file_r(dtype, dtype_size)
        
        file.remove(METADATA_FILE)
        
        temp_data_file_size <- length(result)
        metadata_file_cw(temp_data_file_size, dtype)
        file.rename(RESULT_FILE, DATA_FILE)
    }
    
    cleanup()
    return(result)
}

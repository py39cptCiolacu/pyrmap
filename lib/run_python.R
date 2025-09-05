DATA_FILE <- "data.bin"
RESULT_FILE <- "result.bin"
METADATA_FILE <- "metadata.bin"
METADATA_FILE_SIZE <- 8 + 4 + 4

# c - create
# r - read
# w - write
# d - delete

metadata_file_cw <- function(input_size) {

    con <- file(METADATA_FILE, "wb")
    writeBin(rep(as.raw(0), METADATA_FILE_SIZE), con)
    close(con)

    con <- file(METADATA_FILE, "r+b")
    writeBin(as.integer(0), con, size = 8)
    writeBin(as.integer(input_size), con, size = 4)
    writeBin(as.integer(0), con, size = 4)
    close(con)
}

data_file_cw <- function(data, data_file_size) {

    con <- file(DATA_FILE, "wb")
    writeBin(rep(as.raw(0), data_file_size), con)
    close(con)

    con <- file(DATA_FILE, "r+b")
    writeBin(as.numeric(data), con, size = 4)                  
    close(con)
}

get_result_file_size <- function() {

    con <- file(METADATA_FILE, "rb")
    raw_metadata <- readBin(con, "raw", n = METADATA_FILE_SIZE)
    close(con)

    metadata_flag <- readBin(raw_metadata[1:8], "integer", size = 8, endian = "little")
    if (metadata_flag != 1) stop("Python didn't write result size")
    
    result_size = readBin(raw_metadata[13:16], "integer", size = 4, endian = "little")

    return(result_size)
}

result_file_r <- function() {
    
    result_size <- get_result_file_size()

    con <- file(RESULT_FILE, "rb")
    result <- readBin(con, "numeric", size = 4, n = result_size, endian = "little")
    close(con)

    return(result)
}

cleanup <- function() {
    
    if (file.exists(DATA_FILE)) {
        file.remove(DATA_FILE)
    }
    if (file.exists(METADATA_FILE)) {
        file.remove(METADATA_FILE)
    }
    if (file.exists(RESULT_FILE)) {
        file.remove(RESULT_FILE)
    }
}


run_python <- function(data, python_script_path) {

    library(processx)
    input_size <- length(data)

    metadata_file_cw(input_size)
    data_file_cw(data, 4*input_size)

    processx::run("python3", args = python_script_path)
    result = result_file_r()

    cleanup()
    return(result)
}

run_python_shared_data <- function(data, python_scripts_paths) {
    library(processx)
    results <- c()

    input_size <- length(data)
    metadata_file_cw(input_size) #change this to a flag change only
    data_file_cw(data, 4*input_size)
    
    for (python_script_path in python_scripts_paths) {
        processx::run("python3", args = python_script_path)
        
        result <- result_file_r()
        results <- c(results, result)
        file.remove(RESULT_FILE)

        metadata_file_cw(input_size) #change this to a flag change only
    }

    cleanup()
    return(results)
}

run_python_pipeline <- function(initial_data, python_scripts_paths) {
    library(processx)
    initial_input_size <- length(initial_data)
    metadata_file_cw(initial_input_size)
    data_file_cw(initial_data, 4*initial_input_size)

    for (python_script_path in python_scripts_paths) {
        processx::run("python3", args = python_script_path)
        result <- result_file_r()
        
        file.remove(METADATA_FILE)
        
        temp_data_file_size <- length(result)
        metadata_file_cw(temp_data_file_size)
        file.rename(RESULT_FILE, DATA_FILE)
    }
    
    cleanup()
    return(result)
}

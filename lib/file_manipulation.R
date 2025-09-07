DATA_FILE <- "data.bin"
RESULT_FILE <- "result.bin"
METADATA_FILE <- "metadata.bin"
METADATA_FILE_SIZE <- 8 + 4 + 4 + 4 

# c - create
# r - read
# w - write
# d - delete

metadata_file_cw <- function(input_size, dtype) {

    con <- file(METADATA_FILE, "wb")
    writeBin(rep(as.raw(0), METADATA_FILE_SIZE), con)
    close(con)

    con <- file(METADATA_FILE, "r+b")
    writeBin(as.integer(0), con, size = 8)  # flag
    writeBin(as.integer(input_size), con, size = 4) #input size
    writeBin(as.integer(dtype), con, size = 4) # dtype
    writeBin(as.integer(0), con, size = 4) # result (0 for now, cause we dont know) - this might do nothing 
    close(con)
}

data_file_cw <- function(data, data_file_size, dtype) {

    con <- file(DATA_FILE, "wb")
    writeBin(rep(as.raw(0), data_file_size), con)
    close(con)
    
    con <- file(DATA_FILE, "r+b")
    
    if (dtype == 1){
        writeBin(as.numeric(data), con, size = 4)                  
    }
    else if (dtype == 2){
        writeBin(as.numeric(data), con, size = 8)                  
    }
    else if (dtype == 3){
        writeBin(as.integer(data), con, size = 4)                  
    }
    else if (dtype == 4){
        writeBin(as.integer(data), con, size = 8)                  
    }
    else if (dtype == 5){
        writeBin(as.raw(data), con, size = 1)
    }

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

result_file_r <- function(dtype, dtype_size) {
    
    result_size <- get_result_file_size()

    con <- file(RESULT_FILE, "rb")

    if (dtype == 1 || dtype == 2){
        result <- readBin(con, "numeric", size = dtype_size, n = result_size, endian = "little")
    }
    else if (dtype == 3 || dtype == 4){
        result <- readBin(con, "integer", size = dtype_size, n = result_size, endian = "little")
    }
    else if (dtype == 5){
        result <- readBin(con, "integer", size = dtype_size, n = result_size, endian = "little")
    }
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

get_size_per_type <-function(dtype) {
    if (dtype == 1){
        return(4)
    }
    else if (dtype == 2){
        return(8)
    }
    else if (dtype == 3){
        return(4)
    }
    else if (dtype == 4){
        return(8)
    }
    else if (dtype == 5){
        return(1)
    }
    else{
        return(-1)
    }
}

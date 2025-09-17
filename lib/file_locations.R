DATA_FILE_RAM <- "/dev/shm/data.bin"
RESULT_FILE_RAM <- "/dev/shm/result.bin"
METADATA_FILE <- "/dev/shm/metadata.bin"

DATA_FILE_DISK <- "/home/pyrmap/storage/data.bin"
RESULT_FILE_DISK <- "/home/pyrmap/storage/result.bin"


get_data_file_path <- function(path){
    if (path == "RAM") {return (DATA_FILE_RAM)}
    if (path == "DISK") {return (DATA_FILE_DISK)}
    stop("Path can be either RAM or DISK")
}

get_result_file_path <- function(path){
    if (path == "RAM") {return (RESULT_FILE_RAM)}
    if (path == "DISK") {return (RESULT_FILE_DISK)}
    stop("Path can be either RAM or DISK")
}

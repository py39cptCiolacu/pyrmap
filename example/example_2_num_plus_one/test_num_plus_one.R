source("../../lib/run_python.R")
input_data <- c(100)
python_script_path_num_plus_one <- "num_plus_one.py"

result <- run_python(
    data = input_data,
    python_script_path=python_script_path_num_plus_one,
    dtype = "int64"
)

print(result)


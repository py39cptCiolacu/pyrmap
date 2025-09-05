source("/home/shared_memory/pyrmap/lib/run_python.R")

input_data <- c(100)
python_script_path_num_plus_one <- "/home/shared_memory/pyrmap/example/num_plus_one.py"

result <- run_python(
    data = input_data,
    python_script_path=python_script_path_num_plus_one
)

print(result)


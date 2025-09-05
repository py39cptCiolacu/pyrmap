source("/home/shared_memory/pyrmap/lib/run_python.R")

input_data <- seq(1000000)
python_script_path_num_plus_one <- "/home/shared_memory/pyrmap/example/performance.py"

result <- run_python(
    data = input_data,
    python_script_path=python_script_path_num_plus_one
)


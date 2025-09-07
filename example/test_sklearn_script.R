source("/home/shared_memory/pyrmap/lib/run_python.R")

input_data <- c(1, 6, 14, 7)
python_script_path_sum <- "/home/shared_memory/pyrmap/example/sklearn_script.py"

result <- run_python(
    data = input_data,
    python_script_path=python_script_path_sum,
)

print(result)

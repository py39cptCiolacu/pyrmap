source("/home/shared_memory/pyrmap/lib/run_python.R")

input_data <- c(1, 6, 14, 7)
python_script_path_sum <- "/home/shared_memory/pyrmap/example/sum.py"

result <- run_python(
    data = input_data,
    python_script_path=python_script_path_sum,
    dtype="int32"
)

print(result)

source("/home/shared_memory/pyrmap/lib/run_python.R")

input_data <- seq(1:10)
python_script_path_sum <- "/home/shared_memory/pyrmap/example/sum.py"
python_script_path_num_plus_one <- "/home/shared_memory/pyrmap/example/num_plus_one.py"

result <- run_python_pipeline(
    initial_data = input_data,
    python_scripts_paths = c(python_script_path_sum, python_script_path_num_plus_one, python_script_path_num_plus_one)
)

print(paste("RESULT", result))

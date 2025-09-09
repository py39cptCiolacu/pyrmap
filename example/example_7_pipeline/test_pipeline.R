source("../../lib/run_python.R")

input_data <- seq(1:10)
python_script_path_sum <- "sum.py"
python_script_path_num_plus_one <- "num_plus_one.py"

result <- run_python_pipeline(
    initial_data = input_data,
    python_scripts_paths = c(python_script_path_sum, python_script_path_num_plus_one, python_script_path_num_plus_one)
)

print(paste("RESULT", result))

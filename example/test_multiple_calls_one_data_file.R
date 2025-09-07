source("/home/shared_memory/pyrmap/lib/run_python.R")

input_data <- seq(1:10)
python_script_path_sum <- "/home/shared_memory/pyrmap/example/sum.py"
python_script_path_product <- "/home/shared_memory/pyrmap/example/product.py"

results <- run_python_shared_data(
    data = input_data,
    python_scripts_paths = c(python_script_path_sum, python_script_path_product),
    dtype = 1
)

print(paste("SUM", results))

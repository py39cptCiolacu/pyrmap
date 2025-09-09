source("../../lib/run_python.R")

input_data <- seq(1:10)
python_script_path_sum <- "sum.py"
python_script_path_product <- "product.py"

results <- run_python_shared_data(
    data = input_data,
    python_scripts_paths = c(python_script_path_sum, python_script_path_product),
)

print(paste("SUM", results))

source("/home/shared_memory/pyrmap/lib/run_python.R")

input_data <- seq(1:10)
python_script_path_sum <- "/home/shared_memory/pyrmap/example/sum.py"
python_script_path_product <- "/home/shared_memory/pyrmap/example/product.py"

result_sum <- run_python(
    data = input_data,
    python_script_path=python_script_path_sum,
    delete_data_file = FALSE
)

result_product <- run_python(
    data = input_data,
    python_script_path=python_script_path_product,
    create_data_file = FALSE
)

print(paste("SUM", result_sum))
print(paste("PRODUCT", result_product))

source("/home/shared_memory/pyrmap/lib/run_python.R")

python_script_path = "/home/shared_memory/pyrmap/example/sklearn_complex.py"

X <- matrix(c(
    0, 0,
    1, 1,
    0, 1,
    1, 0
), nrow = 4, byrow = TRUE)

y <- c(0, 1, 1, 0)

input_data <- c(as.vector(t(X)), y)

result <- run_python(
    data = input_data,
    python_script_path= python_script_path,
    dtype = 3
)



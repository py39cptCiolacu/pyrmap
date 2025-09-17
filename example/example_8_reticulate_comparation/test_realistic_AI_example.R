source("../../lib/run_python.R")

python_script_path_ai <- "AI_realistic.py"
#python_script_path_prediction <- "/home/shared_memory/pyrmap/example/AI_realistic_prediction.py"

N <- 200e6
set.seed(42)
data_vector <- runif(N)

result <- run_python(
    data = data_vector,
    python_script_path = python_script_path_ai,
    dtype = "float32",
    path="DISK"
)

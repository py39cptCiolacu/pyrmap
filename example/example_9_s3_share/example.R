source("../../lib/run_python.R")

python_script<- "read_and_print_s3.py"

my_class <- function(a, b) {
    structure(
        list(
            a = a, 
            b = b
        ),
        class = "my_class"
    )
}

x <- my_class(10L, 20L)

run_python_share_s3(x, python_script)

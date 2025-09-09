library(reticulate)

use_virtualenv("../../.venv", required = TRUE)

np <- import("numpy")
sklearn <- import("sklearn.linear_model")

N <- 50e6
n_features <- 10
n_samples <- N %/% (n_features + 1)

set.seed(42)
data_vector <- runif(N)

X <- matrix(data_vector[1:(n_samples * n_features)], ncol = n_features)
y <- data_vector[(n_samples * n_features + 1):(n_samples * (n_features + 1))]
y <- as.integer(y > 0.5)

X_np <- np$array(X, dtype = "float32")
y_np <- np$array(y, dtype = "int32")

LogisticRegression <- sklearn$LogisticRegression
model <- LogisticRegression(max_iter = as.integer(200))

model$fit(X_np, y_np)

preds <- model$predict(X_np)
preds_r <- as.integer(preds)

import numpy as np
from sklearn.linear_model import LogisticRegression
from lib.process_with_mmap import process_via_mmap

@process_via_mmap
def train_model_mmap(input_data):
    n_features = 10

    total_elements = input_data.size
    n_samples = total_elements // (n_features + 1)  # fiecare sample are 10 features + 1 label

    X = input_data[:n_samples * n_features].reshape(n_samples, n_features)
    y = input_data[n_samples * n_features : n_samples * (n_features + 1)]
    y = (y > 0.5).astype(int)  # transformăm în 0/1 pentru clasificare

    model = LogisticRegression(max_iter=200)
    model.fit(X, y)

    predictions = model.predict(X)
    return predictions.astype(np.int32)

if __name__ == "__main__":
    train_model_mmap()

import numpy as np
from sklearn.linear_model import LogisticRegression
from lib.process_with_mmap import process_via_mmap

@process_via_mmap
def train_model_mmap(input_data):
    
    n_samples = 4
    n_features = 2

    total_X_size = n_features * n_samples
    X = input_data[:total_X_size].reshape(n_samples, n_features)
    y = input_data[total_X_size:].astype(int)

    model = LogisticRegression()
    model.fit(X, y)

    predictions = model.predict(X)
    return predictions.astype(np.int32)

if __name__ == "__main__":
    train_model_mmap()

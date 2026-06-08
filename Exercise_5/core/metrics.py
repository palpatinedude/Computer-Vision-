import numpy as np


# computes mean squared error
def mse(X, X_hat):
    return np.mean(
        (X - X_hat) ** 2
    )


# computes reconstruction error for each sample
def sample_mse(
    X,
    X_hat
):
    return np.mean(
        (X - X_hat) ** 2,
        axis=1
    )
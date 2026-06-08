import numpy as np


# fits PCA using singular value decomposition
def fit_pca(X):
    # computes mean image
    mean = X.mean(axis=0)

    # centers data
    X_centered = X - mean

    _, S, Vt = np.linalg.svd(
        X_centered,
        full_matrices=False
    )

    # stores principal components
    components = Vt

    # computes covariance eigenvalues
    eigenvalues = (
        S ** 2
    ) / (
        X.shape[0] - 1
    )

    return (
        mean,
        components,
        eigenvalues
    )


# projects data to PCA latent space
def encode(
    X,
    mean,
    components,
    L
):
    # centers data using training mean
    X_centered = X - mean

    # keeps first L principal components
    V_L = components[:L]

    Z = X_centered @ V_L.T

    return Z


# reconstructs data from PCA latent space
def decode(
    Z,
    mean,
    components,
    L,
    clip=True
):
    # keeps first L principal components
    V_L = components[:L]

    X_hat = Z @ V_L + mean

    # clips reconstructed values to image range
    if clip:
        X_hat = np.clip(
            X_hat,
            0,
            1
        )

    return X_hat


# encodes and reconstructs data with PCA
def reconstruct(
    X,
    mean,
    components,
    L,
    clip=True
):
    Z = encode(
        X,
        mean,
        components,
        L
    )

    X_hat = decode(
        Z,
        mean,
        components,
        L,
        clip
    )

    return X_hat, Z
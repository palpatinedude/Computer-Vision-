import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


IMAGE_SHAPE = (28, 28)

ROOT_DIR = os.path.dirname(
    os.path.abspath(__file__)
)

DATA_DIR = os.path.join(ROOT_DIR, "data")

TRAIN_PATH = os.path.join(
    DATA_DIR,
    "mnist_train.csv"
)

TEST_PATH = os.path.join(
    DATA_DIR,
    "mnist_test.csv"
)

L_VALUES = [1, 8, 16, 64, 256]
DIGITS = [0, 8]
FIG_DPI = 200


# creates output directories
def ensure_dirs(*dirs):
    for directory in dirs:
        os.makedirs(directory, exist_ok=True)


# loads MNIST data from CSV file
def load_mnist_csv(path):
    df = pd.read_csv(path)

    y = df.iloc[:, 0].values
    X = df.iloc[:, 1:].values.astype(np.float64) / 255.0

    return X, y


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
    eigenvalues = (S ** 2) / (X.shape[0] - 1)

    return mean, components, eigenvalues


# projects data to PCA latent space
def encode(X, mean, components, L):
    # centers data using training mean
    X_centered = X - mean

    # keeps first L principal components
    V_L = components[:L]

    Z = X_centered @ V_L.T

    return Z


# reconstructs data from PCA latent space
def decode(Z, mean, components, L, clip=True):
    # keeps first L principal components
    V_L = components[:L]

    X_hat = Z @ V_L + mean

    # clips reconstructed values to image range
    if clip:
        X_hat = np.clip(X_hat, 0, 1)

    return X_hat


# encodes and reconstructs data with PCA
def reconstruct(X, mean, components, L, clip=True):
    Z = encode(X, mean, components, L)
    X_hat = decode(Z, mean, components, L, clip=clip)

    return X_hat, Z


# computes mean squared error
def mse(X, X_hat):
    return np.mean((X - X_hat) ** 2)


# computes reconstruction error for each sample
def sample_mse(X, X_hat):
    return np.mean((X - X_hat) ** 2, axis=1)


# normalizes image values for display
def normalize_image_for_display(img):
    img_min = img.min()
    img_max = img.max()

    return (img - img_min) / (img_max - img_min + 1e-8)


# saves images in a single-row grid
def save_image_grid(
    images,
    titles,
    filename,
    cmap="gray",
    image_shape=IMAGE_SHAPE
):
    n = len(images)

    plt.figure(figsize=(2.2 * n, 2.5))

    for i, img in enumerate(images):
        plt.subplot(1, n, i + 1)
        plt.imshow(
            img.reshape(image_shape),
            cmap=cmap
        )
        plt.title(titles[i])
        plt.axis("off")

    plt.tight_layout()
    plt.savefig(filename, dpi=FIG_DPI)
    plt.close()


# saves original and reconstructed image pairs
def save_original_reconstruction_pairs(
    X,
    X_hat,
    y,
    filename,
    n=10,
    image_shape=IMAGE_SHAPE
):
    plt.figure(figsize=(2 * n, 4))

    for i in range(n):
        # plots original image
        plt.subplot(2, n, i + 1)
        plt.imshow(
            X[i].reshape(image_shape),
            cmap="gray"
        )
        plt.title(f"Orig {y[i]}")
        plt.axis("off")

        # plots reconstructed image
        plt.subplot(2, n, n + i + 1)
        plt.imshow(
            X_hat[i].reshape(image_shape),
            cmap="gray"
        )
        plt.title("Recon")
        plt.axis("off")

    plt.tight_layout()
    plt.savefig(filename, dpi=FIG_DPI)
    plt.close()


# saves train and test MSE results
def save_mse_results(filename, train_mse=None, test_mse=None):
    with open(filename, "w") as f:
        if train_mse is not None:
            f.write(f"Train MSE: {train_mse:.6f}\n")

        if test_mse is not None:
            f.write(f"Test MSE: {test_mse:.6f}\n")
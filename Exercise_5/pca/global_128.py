import os
import sys
import numpy as np
import pandas as pd

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from core.config import (
    ensure_dirs,
    TRAIN_PATH,
    TEST_PATH,
)

from core.data_utils import load_mnist_csv
from core.pca_utils import (
    fit_pca,
    reconstruct,
)

from core.metrics import mse
from core.plot_utils import save_original_reconstruction_pairs


OUT_DIR = "results"
FIG_DIR = "figures"

L = 128


def main():
    ensure_dirs(OUT_DIR, FIG_DIR)

    # loads training and test datasets
    X_train, y_train = load_mnist_csv(TRAIN_PATH)
    X_test, y_test = load_mnist_csv(TEST_PATH)

    print("Train:", X_train.shape)
    print("Test:", X_test.shape)

    # fits PCA using the training set only
    mean, components, eigenvalues = fit_pca(X_train)

    # compresses and reconstructs the training set
    X_train_hat, Z_train = reconstruct(
        X_train,
        mean,
        components,
        L
    )

    # compresses and reconstructs the test set
    # using the same PCA basis learned from training
    X_test_hat, Z_test = reconstruct(
        X_test,
        mean,
        components,
        L
    )

    # computes reconstruction errors
    train_mse = mse(X_train, X_train_hat)
    test_mse = mse(X_test, X_test_hat)

    print(f"Global PCA L={L}")
    print("Train MSE:", train_mse)
    print("Test MSE:", test_mse)
    print("Compressed train shape:", Z_train.shape)
    print("Compressed test shape:", Z_test.shape)

    # saves original and reconstructed training images
    save_original_reconstruction_pairs(
        X_train,
        X_train_hat,
        y_train,
        f"{FIG_DIR}/global_pca_train_pairs_L128.png"
    )

    # saves original and reconstructed test images
    save_original_reconstruction_pairs(
        X_test,
        X_test_hat,
        y_test,
        f"{FIG_DIR}/global_pca_test_pairs_L128.png"
    )

    # saves PCA model parameters
    np.save(f"{OUT_DIR}/global_pca_mean.npy", mean)
    np.save(f"{OUT_DIR}/global_pca_components.npy", components)
    np.save(f"{OUT_DIR}/global_pca_eigenvalues.npy", eigenvalues)

    # saves the first L principal components
    np.save(f"{OUT_DIR}/global_pca_V_L_128.npy", components[:L])

    # saves compressed latent representations
    np.save(f"{OUT_DIR}/global_pca_train_compressed.npy", Z_train)
    np.save(f"{OUT_DIR}/global_pca_test_compressed.npy", Z_test)

    # saves reconstruction errors to CSV
    pd.DataFrame([
        {
            "dataset": "train",
            "L": L,
            "mse": train_mse
        },
        {
            "dataset": "test",
            "L": L,
            "mse": test_mse
        }
    ]).to_csv(
        f"{OUT_DIR}/global_pca_L128_errors.csv",
        index=False
    )

    print("Done.")


if __name__ == "__main__":
    main()
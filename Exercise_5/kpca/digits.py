import os
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.decomposition import KernelPCA

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from utils import (
    ensure_dirs,
    load_mnist_csv,
    mse,
    save_image_grid,
    TRAIN_PATH,
    DIGITS,
    L_VALUES,
    FIG_DPI,
)

FIG_DIR = "figures"
OUT_DIR = "results"

GAMMA = 1e-3
MAX_SAMPLES = 1000


# saves original image and reconstructions for different L values
def save_reconstruction_grid(original, reconstructions, digit):
    images = [original] + reconstructions
    titles = ["Original"] + [f"L={L}" for L in L_VALUES]

    save_image_grid(
        images,
        titles,
        f"{FIG_DIR}/kernel_pca_digit_{digit}_reconstructions.png"
    )


# saves mean reconstruction error curve
def save_error_curve(errors, digit):
    plt.figure(figsize=(7, 5))
    plt.plot(L_VALUES, errors, marker="o")
    plt.xlabel("Number of Kernel PCA components L")
    plt.ylabel("Mean Reconstruction MSE")
    plt.title(f"Kernel PCA reconstruction error for digit {digit}")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(
        f"{FIG_DIR}/kernel_pca_digit_{digit}_error_curve.png",
        dpi=FIG_DPI
    )
    plt.close()


# saves reconstruction error histograms
def save_error_histograms(all_errors, digit):
    plt.figure(figsize=(10, 6))

    for L, errors in all_errors.items():
        plt.hist(errors, bins=40, alpha=0.5, label=f"L={L}")

    plt.xlabel("Reconstruction MSE")
    plt.ylabel("Number of samples")
    plt.title(f"Kernel PCA reconstruction error histogram for digit {digit}")
    plt.legend()
    plt.tight_layout()
    plt.savefig(
        f"{FIG_DIR}/kernel_pca_digit_{digit}_error_histograms.png",
        dpi=FIG_DPI
    )
    plt.close()


# runs the kernel PCA experiment for one digit
def run_kernel_pca_for_digit(X, y, digit):
    # keeps only the selected digit samples
    X_digit = X[y == digit]
    X_digit = X_digit[:MAX_SAMPLES]

    print(f"\nDigit {digit}")
    print("Samples used:", X_digit.shape[0])

    sample = X_digit[0]
    reconstructions = []
    mean_errors = []
    histogram_errors = {}

    # evaluates different latent dimensions
    for L in L_VALUES:
        print(f"Running Kernel PCA for digit {digit}, L={L}")

        kpca = KernelPCA(
            n_components=L,
            kernel="rbf",
            gamma=GAMMA,
            fit_inverse_transform=True,
            alpha=1e-3
        )

        # computes latent representation
        Z = kpca.fit_transform(X_digit)

        # reconstructs images from latent space
        X_hat = kpca.inverse_transform(Z)
        X_hat = np.clip(X_hat, 0, 1)

        # computes reconstruction error per image
        errors = np.mean((X_digit - X_hat) ** 2, axis=1)
        mean_mse = np.mean(errors)

        histogram_errors[L] = errors
        mean_errors.append(mean_mse)
        reconstructions.append(X_hat[0])

        print(f"L={L}, Mean MSE={mean_mse:.6f}")

    # saves visual results
    save_reconstruction_grid(sample, reconstructions, digit)
    save_error_curve(mean_errors, digit)
    save_error_histograms(histogram_errors, digit)

    # saves reconstruction errors
    result_df = pd.DataFrame({
        "L": L_VALUES,
        "mean_mse": mean_errors
    })

    result_df.to_csv(
        f"{OUT_DIR}/kernel_pca_digit_{digit}_errors.csv",
        index=False
    )


def main():
    ensure_dirs(OUT_DIR, FIG_DIR)

    # loads MNIST dataset
    X, y = load_mnist_csv(TRAIN_PATH)

    # runs KPCA separately for each digit
    for digit in DIGITS:
        run_kernel_pca_for_digit(X, y, digit)

    print("\nDone.")


if __name__ == "__main__":
    main()
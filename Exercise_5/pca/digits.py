import os
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from utils import (
    ensure_dirs,
    load_mnist_csv,
    fit_pca,
    reconstruct,
    mse,
    sample_mse,
    normalize_image_for_display,
    save_image_grid,
    L_VALUES,
    DIGITS,
    FIG_DPI,
    TRAIN_PATH,
)

OUT_DIR = "results"
FIG_DIR = "figures"


# saves the first 8 principal components as images
def save_components_grid(components, digit):
    images = []
    titles = []

    for i in range(8):
        pc = components[i]

        # normalize PCA component only for visualization
        pc_norm = normalize_image_for_display(pc)

        images.append(pc_norm)
        titles.append(f"PC {i + 1}")

    save_image_grid(
        images,
        titles,
        f"{FIG_DIR}/digit_{digit}_first_8_pcs.png"
    )


# saves original image and its reconstructions for different L values
def save_reconstructions(X_digit, mean, components, digit):
    sample = X_digit[0]

    images = [sample]
    titles = ["Original"]

    for L in L_VALUES:
        rec, _ = reconstruct(
            sample[None, :],
            mean,
            components,
            L
        )

        images.append(rec[0])
        titles.append(f"L={L}")

    save_image_grid(
        images,
        titles,
        f"{FIG_DIR}/digit_{digit}_reconstructions.png"
    )


# saves histograms of reconstruction errors for different L values
def save_error_histograms(X_digit, mean, components, digit):
    plt.figure(figsize=(12, 7))

    for L in L_VALUES:
        X_hat, _ = reconstruct(
            X_digit,
            mean,
            components,
            L
        )

        # computes reconstruction error for each image
        errors = sample_mse(X_digit, X_hat)

        plt.hist(
            errors,
            bins=40,
            alpha=0.5,
            label=f"L={L}"
        )

    plt.xlabel("Reconstruction MSE")
    plt.ylabel("Number of samples")
    plt.title(f"Reconstruction error histogram for digit {digit}")
    plt.legend()
    plt.tight_layout()
    plt.savefig(
        f"{FIG_DIR}/digit_{digit}_error_histograms.png",
        dpi=FIG_DPI
    )
    plt.close()


# saves mean reconstruction error curve for different L values
def save_error_curve(X_digit, mean, components, digit):
    errors = []

    for L in L_VALUES:
        X_hat, _ = reconstruct(
            X_digit,
            mean,
            components,
            L
        )

        # computes mean reconstruction error for all images
        error = mse(X_digit, X_hat)
        errors.append(error)

    plt.figure(figsize=(7, 5))
    plt.plot(L_VALUES, errors, marker="o")
    plt.xlabel("Number of principal components L")
    plt.ylabel("Mean Reconstruction MSE")
    plt.title(f"Mean reconstruction error for digit {digit}")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(
        f"{FIG_DIR}/digit_{digit}_error_curve.png",
        dpi=FIG_DPI
    )
    plt.close()

    return errors


# runs the full PCA experiment for one digit
def run_digit_experiment(X, y, digit):
    # keeps only the images that belong to the selected digit
    X_digit = X[y == digit]

    print(f"Digit {digit}: {X_digit.shape[0]} samples")

    # fits PCA only on this digit
    mean, components, eigenvalues = fit_pca(X_digit)

    # saves the mean image of this digit
    save_image_grid(
        [mean],
        [f"Mean digit {digit}"],
        f"{FIG_DIR}/digit_{digit}_mean.png"
    )

    save_components_grid(components, digit)
    save_reconstructions(X_digit, mean, components, digit)
    save_error_histograms(X_digit, mean, components, digit)

    errors = save_error_curve(X_digit, mean, components, digit)

    # saves PCA results for later use
    np.save(f"{OUT_DIR}/digit_{digit}_mean.npy", mean)
    np.save(f"{OUT_DIR}/digit_{digit}_components.npy", components)
    np.save(f"{OUT_DIR}/digit_{digit}_eigenvalues.npy", eigenvalues)

    summary_rows = []

    # stores reconstruction errors in table format
    for L, error in zip(L_VALUES, errors):
        summary_rows.append({
            "digit": digit,
            "L": L,
            "mean_mse": error
        })

    return summary_rows


def main():
    ensure_dirs(OUT_DIR, FIG_DIR)

    # loads MNIST images and labels
    X, y = load_mnist_csv(TRAIN_PATH)

    summary = []

    # runs PCA separately for each selected digit
    for digit in DIGITS:
        rows = run_digit_experiment(X, y, digit)
        summary.extend(rows)

    # saves all reconstruction errors in one CSV file
    summary_df = pd.DataFrame(summary)
    summary_df.to_csv(
        f"{OUT_DIR}/pca_reconstruction_errors.csv",
        index=False
    )

    print("\nDone.")
    print(summary_df)


if __name__ == "__main__":
    main()
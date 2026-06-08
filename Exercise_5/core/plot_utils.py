import matplotlib.pyplot as plt

from .config import (
    IMAGE_SHAPE,
    FIG_DPI,
)

# normalizes image values for display
def normalize_image_for_display(img):
    img_min = img.min()
    img_max = img.max()

    return (
        img - img_min
    ) / (
        img_max - img_min + 1e-8
    )

# saves images in a single-row grid
def save_image_grid(
    images,
    titles,
    filename,
    cmap="gray",
    image_shape=IMAGE_SHAPE
):
    n = len(images)

    plt.figure(
        figsize=(2.2 * n, 2.5)
    )

    for i, img in enumerate(images):

        plt.subplot(
            1,
            n,
            i + 1
        )

        plt.imshow(
            img.reshape(
                image_shape
            ),
            cmap=cmap
        )

        plt.title(
            titles[i]
        )

        plt.axis("off")

    plt.tight_layout()

    plt.savefig(
        filename,
        dpi=FIG_DPI
    )

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
    plt.figure(
        figsize=(2 * n, 4)
    )

    for i in range(n):

        # plots original image
        plt.subplot(
            2,
            n,
            i + 1
        )

        plt.imshow(
            X[i].reshape(
                image_shape
            ),
            cmap="gray"
        )

        plt.title(
            f"Orig {y[i]}"
        )

        plt.axis("off")

        # plots reconstructed image
        plt.subplot(
            2,
            n,
            n + i + 1
        )

        plt.imshow(
            X_hat[i].reshape(
                image_shape
            ),
            cmap="gray"
        )

        plt.title(
            "Recon"
        )

        plt.axis("off")

    plt.tight_layout()

    plt.savefig(
        filename,
        dpi=FIG_DPI
    )

    plt.close()


# saves training loss curve
def save_loss_curve(
    losses,
    filename,
    title
):
    plt.figure()

    plt.plot(
        range(
            1,
            len(losses) + 1
        ),
        losses
    )

    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.title(title)

    plt.grid(True)

    plt.tight_layout()

    plt.savefig(
        filename,
        dpi=FIG_DPI
    )

    plt.close()
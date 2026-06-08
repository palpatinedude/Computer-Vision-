import sys
import torch
import torch.optim as optim
import torch.nn.functional as F
import matplotlib.pyplot as plt
import numpy as np

sys.path.append("..")

from core.config import ensure_dirs, FIG_DPI
from core.data_utils import get_data_loaders
from core.train_utils import count_parameters
from core.plot_utils import save_loss_curve, save_original_reconstruction_pairs
from models import VAE


BATCH_SIZE = 250
EPOCHS = 100
LR = 1e-3
N_FIXED_NOISE = 10

FIG_DIR = "figures"
RESULTS_DIR = "results"


# computes VAE loss
def vae_loss_function(x_hat, x, mu, logvar):
    # computes reconstruction loss
    bce = F.binary_cross_entropy(
        x_hat,
        x,
        reduction="sum"
    )

    # computes KL divergence loss
    kld = -0.5 * torch.sum(
        1 + logvar - mu.pow(2) - logvar.exp()
    )

    # combines reconstruction and regularization losses
    loss = bce + kld

    return loss, bce, kld


# saves generated images from fixed latent noise
def save_generated_from_noise(model, fixed_noise, filename):
    model.eval()

    with torch.no_grad():
        # decodes fixed latent vectors
        samples = model.decode(fixed_noise)

    samples = samples.cpu().numpy()
    n = samples.shape[0]

    plt.figure(figsize=(2 * n, 2))

    for i in range(n):
        plt.subplot(1, n, i + 1)
        plt.imshow(samples[i].reshape(28, 28), cmap="gray")
        plt.title(f"z{i+1}")
        plt.axis("off")

    plt.tight_layout()
    plt.savefig(filename, dpi=FIG_DPI)
    plt.close()


# saves VAE reconstruction examples
def save_vae_reconstructions(model, test_loader, device, filename):
    model.eval()

    with torch.no_grad():
        # gets one batch from test set
        x, y = next(iter(test_loader))

        x = x.to(device)
        x_hat, _, _ = model(x)

    save_original_reconstruction_pairs(
        x.cpu().numpy(),
        x_hat.cpu().numpy(),
        y.numpy(),
        filename,
        n=10
    )


# saves latent space scatter plot
def save_latent_space(model, test_loader, device, filename):
    model.eval()

    # stores latent means and labels
    all_mu = []
    all_labels = []

    with torch.no_grad():
        for x, y in test_loader:
            x = x.to(device)

            # computes latent distribution parameters
            mu, logvar = model.encode(x)

            all_mu.append(mu.cpu().numpy())
            all_labels.append(y.numpy())

    all_mu = np.concatenate(all_mu, axis=0)
    all_labels = np.concatenate(all_labels, axis=0)

    plt.figure(figsize=(8, 6))

    scatter = plt.scatter(
        all_mu[:, 0],
        all_mu[:, 1],
        c=all_labels,
        cmap="tab10",
        s=6,
        alpha=0.7
    )

    plt.xlabel("z1")
    plt.ylabel("z2")
    plt.title("VAE Latent Space of Test Data")
    plt.colorbar(scatter, ticks=range(10), label="Digit label")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(filename, dpi=FIG_DPI)
    plt.close()


# trains variational autoencoder model
def train_vae(model, train_loader, optimizer, device, epochs, fixed_noise):
    # stores training loss per epoch
    losses = []

    # defines epochs for generated sample snapshots
    snapshot_epochs = [1, 50, 100]

    model.train()

    for epoch in range(epochs):
        epoch_loss = 0.0

        for x, _ in train_loader:
            x = x.to(device)

            optimizer.zero_grad()

            # computes reconstruction and latent parameters
            x_hat, mu, logvar = model(x)

            # computes VAE loss
            loss, bce, kld = vae_loss_function(
                x_hat,
                x,
                mu,
                logvar
            )

            loss.backward()
            optimizer.step()

            epoch_loss += loss.item()

        # computes average loss per sample
        epoch_loss = epoch_loss / len(train_loader.dataset)
        losses.append(epoch_loss)

        current_epoch = epoch + 1

        print(
            f"Epoch [{current_epoch}/{epochs}], "
            f"Loss: {epoch_loss:.6f}"
        )

        # saves generated samples at selected epochs
        if current_epoch in snapshot_epochs:
            save_generated_from_noise(
                model,
                fixed_noise,
                f"{FIG_DIR}/vae_noise_epoch_{current_epoch}.png"
            )

            model.train()

    return losses


# runs VAE experiment
def main():
    # creates output directories
    ensure_dirs(FIG_DIR, RESULTS_DIR)

    # selects CPU or GPU
    device = torch.device(
        "cuda" if torch.cuda.is_available() else "cpu"
    )

    print("Using device:", device)

    # loads datasets
    train_loader, test_loader = get_data_loaders(BATCH_SIZE)

    # creates VAE model
    model = VAE().to(device)

    # counts trainable parameters
    total_params = count_parameters(model)
    print("Total trainable parameters:", total_params)

    # creates optimizer
    optimizer = optim.Adam(
        model.parameters(),
        lr=LR
    )

    # samples fixed Gaussian noise
    fixed_noise = torch.randn(
        N_FIXED_NOISE,
        model.latent_dim
    ).to(device)

    # trains VAE
    losses = train_vae(
        model,
        train_loader,
        optimizer,
        device,
        EPOCHS,
        fixed_noise
    )

    # saves training loss curve
    save_loss_curve(
        losses,
        f"{FIG_DIR}/vae_loss_curve.png",
        "VAE Training Loss"
    )

    # saves reconstruction examples
    save_vae_reconstructions(
        model,
        test_loader,
        device,
        f"{FIG_DIR}/vae_reconstructions.png"
    )

    # saves latent space plot
    save_latent_space(
        model,
        test_loader,
        device,
        f"{FIG_DIR}/vae_latent_space.png"
    )

    # saves VAE results
    with open(f"{RESULTS_DIR}/vae_results.txt", "w") as f:
        f.write(f"Total parameters: {total_params}\n")
        f.write(f"Final loss: {losses[-1]:.6f}\n")

    # saves trained VAE model
    torch.save(
        model.state_dict(),
        f"{RESULTS_DIR}/vae_model.pt"
    )

    print("Done.")


if __name__ == "__main__":
    main()
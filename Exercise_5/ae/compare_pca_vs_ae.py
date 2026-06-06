import sys
import os
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
import matplotlib.pyplot as plt
import pandas as pd

from torch.utils.data import DataLoader, TensorDataset

sys.path.append("..")

from utils import (
    ensure_dirs,
    load_mnist_csv,
    save_original_reconstruction_pairs,
    mse,
    TRAIN_PATH,
    TEST_PATH,
)

from models import LinearAE


BATCH_SIZE = 250
EPOCHS = 40
LR = 1e-3

FIG_DIR = "figures"
RESULTS_DIR = "results"

PCA_PATH = "../pca/results/global_pca_V_L_128.npy"


# normalizes rows to unit norm
def row_normalize(A):
    norms = np.linalg.norm(A, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    return A / norms


# computes mean best-match cosine similarity
# between PCA components and AE encoder weights
def best_match_similarity(pca_components, ae_weights):
    pca_n = row_normalize(pca_components)
    ae_n = row_normalize(ae_weights)

    cos_matrix = np.abs(pca_n @ ae_n.T)

    best_matches = cos_matrix.max(axis=1)

    return float(np.mean(best_matches))


# loads datasets and creates dataloaders
def get_data_loaders():
    X_train, y_train = load_mnist_csv(TRAIN_PATH)
    X_test, y_test = load_mnist_csv(TEST_PATH)

    X_train = torch.tensor(X_train, dtype=torch.float32)
    y_train = torch.tensor(y_train, dtype=torch.long)

    X_test = torch.tensor(X_test, dtype=torch.float32)
    y_test = torch.tensor(y_test, dtype=torch.long)

    train_dataset = TensorDataset(X_train, y_train)
    test_dataset = TensorDataset(X_test, y_test)

    train_loader = DataLoader(
        train_dataset,
        batch_size=BATCH_SIZE,
        shuffle=True
    )

    test_loader = DataLoader(
        test_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False
    )

    return train_loader, test_loader


# trains the linear autoencoder
def train(model, train_loader, criterion, optimizer, device, pca_components):
    # stores training loss per epoch
    losses = []

    # stores PCA-AE similarity per epoch
    similarities = []

    model.train()

    for epoch in range(EPOCHS):
        epoch_loss = 0.0

        for x, _ in train_loader:
            x = x.to(device)

            optimizer.zero_grad()

            x_hat = model(x)
            loss = criterion(x_hat, x)

            loss.backward()
            optimizer.step()

            epoch_loss += loss.item()

        # computes average training loss
        epoch_loss = epoch_loss / len(train_loader)
        losses.append(epoch_loss)

        # extracts current encoder weights
        ae_weights = model.encoder.weight.detach().cpu().numpy()

        # computes similarity with PCA basis
        sim = best_match_similarity(
            pca_components,
            ae_weights
        )

        similarities.append(sim)

        print(
            f"Epoch [{epoch + 1}/{EPOCHS}], "
            f"Loss: {epoch_loss:.6f}, "
            f"PCA-AE similarity: {sim:.6f}"
        )

    return losses, similarities


# saves training loss curve
def save_loss_curve(losses):
    plt.figure()
    plt.plot(range(1, len(losses) + 1), losses)
    plt.xlabel("Epoch")
    plt.ylabel("BCE Loss")
    plt.title("Linear Autoencoder Training Loss")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f"{FIG_DIR}/linear_ae_loss_curve.png", dpi=200)
    plt.close()


# saves PCA-AE similarity curve and values
def save_similarity_curve(similarities):
    plt.figure()
    plt.plot(range(1, len(similarities) + 1), similarities, marker="o")
    plt.xlabel("Epoch")
    plt.ylabel("Mean best-match cosine similarity")
    plt.title("Similarity between PCA basis and AE encoder weights")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f"{FIG_DIR}/linear_ae_pca_similarity_curve.png", dpi=200)
    plt.close()

    # saves similarity values to CSV
    df = pd.DataFrame({
        "epoch": np.arange(1, len(similarities) + 1),
        "mean_best_match_cosine_similarity": similarities
    })

    df.to_csv(
        f"{RESULTS_DIR}/linear_ae_pca_similarity_per_epoch.csv",
        index=False
    )


# saves reconstruction examples
def save_reconstructions(model, test_loader, device):
    model.eval()

    with torch.no_grad():
        # gets one batch from test set
        x, y = next(iter(test_loader))

        x = x.to(device)
        x_hat = model(x)

        x = x.cpu().numpy()
        x_hat = x_hat.cpu().numpy()
        y = y.cpu().numpy()

    save_original_reconstruction_pairs(
        x,
        x_hat,
        y,
        f"{FIG_DIR}/linear_ae_reconstructions.png",
        n=10
    )


# computes average reconstruction MSE
def compute_mse(model, test_loader, device):
    model.eval()

    total_mse = 0.0

    with torch.no_grad():
        for x, _ in test_loader:
            x = x.to(device)
            x_hat = model(x)

            x = x.cpu().numpy()
            x_hat = x_hat.cpu().numpy()

            total_mse += mse(x, x_hat)

    return total_mse / len(test_loader)


# saves encoder weights
def save_encoder_weights(model):
    encoder_weights = model.encoder.weight.detach().cpu()

    torch.save(
        encoder_weights,
        f"{RESULTS_DIR}/linear_ae_encoder_weights.pt"
    )


def main():
    # creates output directories
    ensure_dirs(FIG_DIR, RESULTS_DIR)

    # selects CPU or GPU
    device = torch.device(
        "cuda" if torch.cuda.is_available() else "cpu"
    )

    print("Using device:", device)

    # loads PCA basis for comparison
    pca_components = np.load(PCA_PATH)

    print("PCA components shape:", pca_components.shape)

    # loads datasets
    train_loader, test_loader = get_data_loaders()

    # creates model
    model = LinearAE().to(device)

    # defines reconstruction loss
    criterion = nn.BCELoss()

    # creates optimizer
    optimizer = optim.Adam(
        model.parameters(),
        lr=LR
    )

    # trains autoencoder
    losses, similarities = train(
        model,
        train_loader,
        criterion,
        optimizer,
        device,
        pca_components
    )

    # saves training curves
    save_loss_curve(losses)
    save_similarity_curve(similarities)

    # saves reconstruction examples
    save_reconstructions(
        model,
        test_loader,
        device
    )

    # computes test reconstruction error
    test_mse = compute_mse(
        model,
        test_loader,
        device
    )

    print(f"Test MSE: {test_mse:.6f}")

    # saves test MSE
    with open(f"{RESULTS_DIR}/linear_ae_mse.txt", "w") as f:
        f.write(f"Test MSE: {test_mse:.6f}\n")

    # saves learned encoder weights
    save_encoder_weights(model)

    # saves trained model
    torch.save(
        model.state_dict(),
        f"{RESULTS_DIR}/linear_ae_model.pt"
    )


if __name__ == "__main__":
    main()
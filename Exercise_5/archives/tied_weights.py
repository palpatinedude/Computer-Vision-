import sys

import torch
import torch.nn as nn
import torch.optim as optim
import matplotlib.pyplot as plt

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

from models import TiedWeightsAE


BATCH_SIZE = 250
EPOCHS = 40
LR = 1e-3

FIG_DIR = "figures"
RESULTS_DIR = "results"


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


# counts trainable model parameters
def count_parameters(model):
    return sum(
        p.numel()
        for p in model.parameters()
        if p.requires_grad
    )


# trains the tied weights autoencoder
def train(model, train_loader, criterion, optimizer, device):
    # stores training loss per epoch
    losses = []

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
        epoch_loss /= len(train_loader)
        losses.append(epoch_loss)

        print(f"Epoch [{epoch + 1}/{EPOCHS}], Loss: {epoch_loss:.6f}")

    return losses


# saves training loss curve
def save_loss_curve(losses):
    plt.figure(figsize=(7, 5))
    plt.plot(range(1, len(losses) + 1), losses)
    plt.xlabel("Epoch")
    plt.ylabel("BCE Loss")
    plt.title("Tied Weights Autoencoder Training Loss")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f"{FIG_DIR}/tied_weights_ae_loss_curve.png", dpi=200)
    plt.close()


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
        f"{FIG_DIR}/tied_weights_ae_reconstructions.png",
        n=10
    )


# computes average reconstruction MSE
def compute_mse(model, test_loader, device):
    model.eval()

    total_mse = 0.0
    num_batches = 0

    with torch.no_grad():
        for x, _ in test_loader:
            x = x.to(device)
            x_hat = model(x)

            x = x.cpu().numpy()
            x_hat = x_hat.cpu().numpy()

            total_mse += mse(x, x_hat)
            num_batches += 1

    return total_mse / num_batches


def main():
    # creates output directories
    ensure_dirs(FIG_DIR, RESULTS_DIR)

    # selects CPU or GPU
    device = torch.device(
        "cuda" if torch.cuda.is_available() else "cpu"
    )

    print("Using device:", device)

    # loads datasets
    train_loader, test_loader = get_data_loaders()

    # creates model
    model = TiedWeightsAE().to(device)

    # counts trainable parameters
    total_params = count_parameters(model)
    print("Total trainable parameters:", total_params)

    # defines reconstruction loss
    criterion = nn.BCELoss()

    # creates optimizer
    optimizer = optim.Adam(
        model.parameters(),
        lr=LR
    )

    # trains autoencoder
    losses = train(
        model,
        train_loader,
        criterion,
        optimizer,
        device
    )

    # saves training loss curve
    save_loss_curve(losses)

    # saves reconstruction examples
    save_reconstructions(model, test_loader, device)

    # computes test reconstruction error
    test_mse = compute_mse(
        model,
        test_loader,
        device
    )

    print(f"Test MSE: {test_mse:.6f}")

    # saves test MSE and parameter count
    with open(f"{RESULTS_DIR}/tied_weights_ae_mse.txt", "w") as f:
        f.write(f"Test MSE: {test_mse:.6f}\n")
        f.write(f"Total parameters: {total_params}\n")

    # saves trained model
    torch.save(
        model.state_dict(),
        f"{RESULTS_DIR}/tied_weights_ae_model.pt"
    )

    print("Done.")


if __name__ == "__main__":
    main()
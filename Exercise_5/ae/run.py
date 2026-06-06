import torch
import torch.nn as nn
import torch.optim as optim
import sys
sys.path.append("..")
from utils import ensure_dirs
from models import LinearAE, NonlinearAE, TiedWeightsAE, PseudoInverseAE

from ae_utils import (
    get_data_loaders,
    count_parameters,
    train_autoencoder,
    compute_test_mse,
    save_loss_curve,
    save_reconstructions,
)


BATCH_SIZE = 250
EPOCHS = 40
LR = 1e-3

FIG_DIR = "figures"
RESULTS_DIR = "results"


# stores model configurations
MODELS = {
    "linear": {
        "class": LinearAE,
        "prefix": "linear_ae",
        "title": "Linear Autoencoder Training Loss",
    },
    "nonlinear": {
        "class": NonlinearAE,
        "prefix": "nonlinear_ae",
        "title": "Nonlinear Autoencoder Training Loss",
    },
    "tied": {
        "class": TiedWeightsAE,
        "prefix": "tied_weights_ae",
        "title": "Tied Weights Autoencoder Training Loss",
    },
    "pseudo": {
        "class": PseudoInverseAE,
        "prefix": "pseudo_inverse_ae",
        "title": "Pseudo-Inverse Autoencoder Training Loss",
    },
}


# runs selected autoencoder experiment
def main(model_name):
    # creates output directories
    ensure_dirs(FIG_DIR, RESULTS_DIR)

    # selects CPU or GPU
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Using device:", device)

    # gets selected model configuration
    config = MODELS[model_name]

    # loads datasets
    train_loader, test_loader = get_data_loaders(BATCH_SIZE)

    # creates selected model
    model = config["class"]().to(device)

    # counts trainable parameters
    total_params = count_parameters(model)
    print("Total trainable parameters:", total_params)

    # defines reconstruction loss
    criterion = nn.BCELoss()

    # creates optimizer
    optimizer = optim.Adam(model.parameters(), lr=LR)

    # trains autoencoder
    losses = train_autoencoder(
        model,
        train_loader,
        criterion,
        optimizer,
        device,
        EPOCHS
    )

    prefix = config["prefix"]

    # saves training loss curve
    save_loss_curve(
        losses,
        f"{FIG_DIR}/{prefix}_loss_curve.png",
        config["title"]
    )

    # saves reconstruction examples
    save_reconstructions(
        model,
        test_loader,
        device,
        f"{FIG_DIR}/{prefix}_reconstructions.png"
    )

    # computes test reconstruction error
    test_mse = compute_test_mse(model, test_loader, device)
    print(f"Test MSE: {test_mse:.6f}")

    # saves test MSE and parameter count
    with open(f"{RESULTS_DIR}/{prefix}_mse.txt", "w") as f:
        f.write(f"Test MSE: {test_mse:.6f}\n")
        f.write(f"Total parameters: {total_params}\n")

    # saves trained model
    torch.save(
        model.state_dict(),
        f"{RESULTS_DIR}/{prefix}_model.pt"
    )

    print("Done.")


if __name__ == "__main__":
    import sys

    # checks command line argument
    if len(sys.argv) != 2:
        print("Usage: python run.py [linear|nonlinear|tied|pseudo]")
        sys.exit(1)

    # runs selected model
    main(sys.argv[1])
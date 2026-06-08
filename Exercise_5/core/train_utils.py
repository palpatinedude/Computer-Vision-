import torch

from .metrics import mse


# counts trainable model parameters
def count_parameters(model):
    return sum(
        p.numel()
        for p in model.parameters()
        if p.requires_grad
    )


# trains standard autoencoder
def train_autoencoder(
    model,
    train_loader,
    criterion,
    optimizer,
    device,
    epochs
):
    # stores training loss per epoch
    losses = []

    model.train()

    for epoch in range(epochs):
        epoch_loss = 0.0

        for x, _ in train_loader:
            x = x.to(device)

            optimizer.zero_grad()

            x_hat = model(x)

            loss = criterion(
                x_hat,
                x
            )

            loss.backward()

            optimizer.step()

            epoch_loss += loss.item()

        # computes average training loss
        epoch_loss /= len(
            train_loader
        )

        losses.append(
            epoch_loss
        )

        print(
            f"Epoch [{epoch+1}/{epochs}], "
            f"Loss: {epoch_loss:.6f}"
        )

    return losses


# computes average test MSE
def compute_test_mse(
    model,
    test_loader,
    device
):
    model.eval()

    total_mse = 0.0

    with torch.no_grad():
        for x, _ in test_loader:

            x = x.to(device)

            x_hat = model(x)

            total_mse += mse(
                x.cpu().numpy(),
                x_hat.cpu().numpy()
            )

    return total_mse / len(
        test_loader
    )
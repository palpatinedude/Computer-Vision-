import pandas as pd
import numpy as np
import torch

from torch.utils.data import (
    DataLoader,
    TensorDataset,
)

from .config import (
    TRAIN_PATH,
    TEST_PATH,
)


# loads MNIST data from CSV file
def load_mnist_csv(path):
    df = pd.read_csv(path)

    y = df.iloc[:, 0].values

    X = (
        df.iloc[:, 1:]
        .values
        .astype(np.float64)
        / 255.0
    )

    return X, y


# loads datasets and creates dataloaders
def get_data_loaders(batch_size):
    X_train, y_train = load_mnist_csv(
        TRAIN_PATH
    )

    X_test, y_test = load_mnist_csv(
        TEST_PATH
    )

    # converts training data to tensors
    X_train = torch.tensor(
        X_train,
        dtype=torch.float32
    )

    y_train = torch.tensor(
        y_train,
        dtype=torch.long
    )

    # converts test data to tensors
    X_test = torch.tensor(
        X_test,
        dtype=torch.float32
    )

    y_test = torch.tensor(
        y_test,
        dtype=torch.long
    )

    # creates training dataloader
    train_loader = DataLoader(
        TensorDataset(X_train, y_train),
        batch_size=batch_size,
        shuffle=True
    )

    # creates test dataloader
    test_loader = DataLoader(
        TensorDataset(X_test, y_test),
        batch_size=batch_size,
        shuffle=False
    )

    return train_loader, test_loader
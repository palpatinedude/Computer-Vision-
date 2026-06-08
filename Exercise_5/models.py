import torch
import torch.nn as nn
import torch.nn.functional as F


class LinearAE(nn.Module):

    def __init__(self):
        super().__init__()

        # creates linear encoder
        self.encoder = nn.Linear(
            784,
            128,
            bias=False
        )

        # creates linear decoder
        self.decoder = nn.Linear(
            128,
            784,
            bias=False
        )

    def forward(self, x):
        # computes latent representation
        z = self.encoder(x)

        # reconstructs input image
        x_hat = torch.sigmoid(
            self.decoder(z)
        )

        return x_hat


class NonlinearAE(nn.Module):

    def __init__(self):
        super().__init__()

        # creates nonlinear encoder
        self.encoder = nn.Sequential(
            nn.Linear(784, 512, bias=False),
            nn.ReLU(),
            nn.Linear(512, 256, bias=False),
            nn.ReLU(),
            nn.Linear(256, 128, bias=False),
            nn.ReLU()
        )

        # creates nonlinear decoder
        self.decoder = nn.Sequential(
            nn.Linear(128, 256, bias=False),
            nn.ReLU(),
            nn.Linear(256, 512, bias=False),
            nn.ReLU(),
            nn.Linear(512, 784, bias=False),
            nn.Sigmoid()
        )

    def forward(self, x):
        # computes latent representation
        z = self.encoder(x)

        # reconstructs input image
        x_hat = self.decoder(z)

        return x_hat


class TiedWeightsAE(nn.Module):

    def __init__(self):
        super().__init__()

        # creates encoder layers
        self.encoder1 = nn.Linear(784, 512, bias=False)
        self.encoder2 = nn.Linear(512, 256, bias=False)
        self.encoder3 = nn.Linear(256, 128, bias=False)

        # creates encoder activation
        self.encoder_activation = nn.LeakyReLU(negative_slope=0.2)

        # creates decoder activation
        self.decoder_activation = nn.LeakyReLU(negative_slope=5.0)

    def encode(self, x):
        # encodes input through tied-weight encoder
        h = self.encoder_activation(self.encoder1(x))
        h = self.encoder_activation(self.encoder2(h))
        z = self.encoder_activation(self.encoder3(h))

        return z

    def decode(self, z):
        # decodes using transposed encoder weights
        h = F.linear(z, self.encoder3.weight.t())
        h = self.decoder_activation(h)

        h = F.linear(h, self.encoder2.weight.t())
        h = self.decoder_activation(h)

        h = F.linear(h, self.encoder1.weight.t())

        # maps output to pixel range
        x_hat = torch.sigmoid(h)

        return x_hat

    def forward(self, x):
        # computes latent representation
        z = self.encode(x)

        # reconstructs input image
        x_hat = self.decode(z)

        return x_hat


class PseudoInverseAE(nn.Module):

    def __init__(self):
        super().__init__()

        # creates encoder layers
        self.encoder1 = nn.Linear(784, 512, bias=False)
        self.encoder2 = nn.Linear(512, 256, bias=False)
        self.encoder3 = nn.Linear(256, 128, bias=False)

        # creates encoder activation
        self.encoder_activation = nn.LeakyReLU(negative_slope=0.2)

        # creates decoder activation
        self.decoder_activation = nn.LeakyReLU(negative_slope=5.0)

    def encode(self, x):
        # encodes input through pseudo-inverse encoder
        h = self.encoder_activation(self.encoder1(x))
        h = self.encoder_activation(self.encoder2(h))
        z = self.encoder_activation(self.encoder3(h))

        return z

    def decode(self, z):
        # computes pseudo-inverse matrices
        W3_pinv = torch.linalg.pinv(self.encoder3.weight)
        W2_pinv = torch.linalg.pinv(self.encoder2.weight)
        W1_pinv = torch.linalg.pinv(self.encoder1.weight)

        # decodes using pseudo-inverse encoder weights
        h = F.linear(z, W3_pinv)
        h = self.decoder_activation(h)

        h = F.linear(h, W2_pinv)
        h = self.decoder_activation(h)

        h = F.linear(h, W1_pinv)

        # maps output to pixel range
        x_hat = torch.sigmoid(h)

        return x_hat

    def forward(self, x):
        # computes latent representation
        z = self.encode(x)

        # reconstructs input image
        x_hat = self.decode(z)

        return x_hat


class VAE(nn.Module):

    def __init__(self, latent_dim=2):
        super().__init__()

        self.latent_dim = latent_dim

        # creates encoder network
        self.encoder = nn.Sequential(
            nn.Linear(784, 512, bias=False),
            nn.ReLU(),
            nn.Linear(512, 256, bias=False),
            nn.ReLU(),
            nn.Linear(256, 128, bias=False),
            nn.ReLU()
        )

        # predicts latent mean
        self.fc_mu = nn.Linear(
            128,
            latent_dim,
            bias=False
        )

        # predicts latent log-variance
        self.fc_logvar = nn.Linear(
            128,
            latent_dim,
            bias=False
        )

        # creates decoder network
        self.decoder = nn.Sequential(
            nn.Linear(latent_dim, 128, bias=False),
            nn.ReLU(),
            nn.Linear(128, 256, bias=False),
            nn.ReLU(),
            nn.Linear(256, 512, bias=False),
            nn.ReLU(),
            nn.Linear(512, 784, bias=False),
            nn.Sigmoid()
        )

    # computes latent distribution parameters
    def encode(self, x):
        h = self.encoder(x)

        mu = self.fc_mu(h)
        logvar = self.fc_logvar(h)

        return mu, logvar

    # samples latent vector using reparameterization trick
    def reparameterize(self, mu, logvar):
        # computes latent standard deviation
        std = torch.exp(0.5 * logvar)

        # samples standard Gaussian noise
        eps = torch.randn_like(std)

        # generates latent sample
        z = mu + std * eps

        return z

    # reconstructs input from latent vector
    def decode(self, z):
        x_hat = self.decoder(z)

        return x_hat

    def forward(self, x):
        # computes latent distribution
        mu, logvar = self.encode(x)

        # samples latent vector
        z = self.reparameterize(mu, logvar)

        # reconstructs input image
        x_hat = self.decode(z)

        return x_hat, mu, logvar
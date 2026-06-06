import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("data/mnist_train.csv")

sample = df.iloc[0]

label = sample.iloc[0]
pixels = sample.iloc[1:].values.reshape(28,28)

plt.imshow(pixels, cmap="gray")
plt.title(f"Digit = {label}")
plt.show()
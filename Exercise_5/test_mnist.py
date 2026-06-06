import pandas as pd

train = pd.read_csv("data/mnist_train.csv")

print(train.shape)
print(train.head())
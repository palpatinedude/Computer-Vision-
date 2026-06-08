import os


# defines project paths

ROOT_DIR = os.path.dirname(
    os.path.dirname(
        os.path.abspath(__file__)
    )
)

DATA_DIR = os.path.join(
    ROOT_DIR,
    "data"
)

TRAIN_PATH = os.path.join(
    DATA_DIR,
    "mnist_train.csv"
)

TEST_PATH = os.path.join(
    DATA_DIR,
    "mnist_test.csv"
)


# defines global constants

IMAGE_SHAPE = (28, 28)

L_VALUES = [1, 8, 16, 64, 256]

DIGITS = [0, 8]

FIG_DPI = 200


# creates output directories
def ensure_dirs(*dirs):
    for directory in dirs:
        os.makedirs(
            directory,
            exist_ok=True
        )
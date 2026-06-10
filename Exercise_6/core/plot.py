import os
import matplotlib.pyplot as plt


def save_pr_curve(pr_results, title, save_path):
    recalls = [item["recall"] for item in pr_results]
    precisions = [item["precision"] for item in pr_results]

    os.makedirs(os.path.dirname(save_path), exist_ok=True)

    plt.figure()
    plt.plot(recalls, precisions, marker="o")
    plt.xlabel("Recall")
    plt.ylabel("Precision")
    plt.title(title)
    plt.grid(True)
    plt.savefig(save_path, dpi=300, bbox_inches="tight")
    plt.close()
import os
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt

path = os.getcwd()
path = os.path.join(path, "../Plot/Linescan Tables/Pulsatility in Sleep.csv")
path = os.path.abspath(path)

print("Reading")
df = pd.read_csv(path, delimiter=";")

# Pulsatility red violin
g = sns.catplot(data=df, x="pulsatility_red", y="state", col="genotype", kind="violin",
            row="vessel_type",
            split=True, inner="stick", bw=.2,
            height=1.5, aspect=6)
g.set_ylabels("")
# g.legend.set_title("Genotype")
g.set_titles(row_template='{row_name}')
g.set_xlabels("Pulsatility (um)")
g.tight_layout()
# plt.show()
path_out = os.getcwd()
path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Pulsatility Red")
path_out = os.path.abspath(path_out)
os.makedirs(os.path.dirname(path_out), exist_ok=True)
plt.savefig(path_out + ".pdf")
plt.close()

# Pulsatility red strip
g = sns.catplot(data=df, x="pulsatility_red", y="state", col="genotype", kind="strip",
            row="vessel_type", hue="mouse",
            dodge=True,
            height=1.5, aspect=6)
g.set_ylabels("")
# g.legend.set_title("Genotype")
g.set_titles(row_template='{row_name}')
g.set_xlabels("Pulsatility (um)")
g.tight_layout()
# plt.show()
path_out = os.getcwd()
path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Pulsatility Red Strip")
path_out = os.path.abspath(path_out)
os.makedirs(os.path.dirname(path_out), exist_ok=True)
plt.savefig(path_out + ".pdf")
plt.close()

# Pulsatility green violin
g = sns.catplot(data=df, x="pulsatility_green", y="state", col="genotype", kind="violin",
            row="vessel_type",
            split=True, inner="stick", bw=.2,
            height=1.5, aspect=6)
g.set_ylabels("")
# g.legend.set_title("Genotype")
g.set_titles(row_template='{row_name}')
g.set_xlabels("Pulsatility (um)")
g.tight_layout()
# plt.show()
path_out = os.getcwd()
path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Pulsatility Green")
path_out = os.path.abspath(path_out)
os.makedirs(os.path.dirname(path_out), exist_ok=True)
plt.savefig(path_out + ".pdf")
plt.close()

# Pulsatility green strip
g = sns.catplot(data=df, x="pulsatility_green", y="state", col="genotype", kind="strip",
            row="vessel_type", hue="mouse",
            dodge=True,
            height=1.5, aspect=6)
g.set_ylabels("")
# g.legend.set_title("Genotype")
g.set_titles(row_template='{row_name}')
g.set_xlabels("Pulsatility (um)")
g.tight_layout()
# plt.show()
path_out = os.getcwd()
path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Pulsatility Green Strip")
path_out = os.path.abspath(path_out)
os.makedirs(os.path.dirname(path_out), exist_ok=True)
plt.savefig(path_out + ".pdf")
plt.close()

# red vs green
g = sns.relplot(data=df, x="pulsatility_green", y="pulsatility_red", hue="state",
                row="genotype", col="vessel_type",
                height=4, aspect=1)
g.tight_layout()
# plt.show()
path_out = os.getcwd()
path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Green vs. Red")
path_out = os.path.abspath(path_out)
os.makedirs(os.path.dirname(path_out), exist_ok=True)
plt.savefig(path_out + ".pdf")
plt.close()

# Hey
for vessel_type in df["vessel_type"].unique():
    df2 = df[df["vessel_type"] == vessel_type]

    # Plot 1
    g = sns.catplot(data=df2, x="pulsatility_green", y="mouse", kind="box",
                    row="state",
                    height=3, aspect=4)
    g.tight_layout()
    # plt.show()
    path_out = os.getcwd()
    path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Green boxplot per mouse %s" % vessel_type)
    path_out = os.path.abspath(path_out)
    os.makedirs(os.path.dirname(path_out), exist_ok=True)
    plt.savefig(path_out + ".pdf")
    plt.close()

    # Plot 2
    g = sns.catplot(data=df2, x="pulsatility_red", y="mouse", kind="box",
                    row="state",
                    height=3, aspect=4)
    g.tight_layout()
    # plt.show()
    path_out = os.getcwd()
    path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Red boxplot per mouse %s" % vessel_type)
    path_out = os.path.abspath(path_out)
    os.makedirs(os.path.dirname(path_out), exist_ok=True)
    plt.savefig(path_out + ".pdf")
    plt.close()

    # Plot 3
    g = sns.catplot(data=df2, x="pulsatility_green", y="mouse", kind="strip",
                    row="state",
                    height=3, aspect=4)
    g.tight_layout()
    # plt.show()
    path_out = os.getcwd()
    path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Green strip per mouse %s" % vessel_type)
    path_out = os.path.abspath(path_out)
    os.makedirs(os.path.dirname(path_out), exist_ok=True)
    plt.savefig(path_out + ".pdf")
    plt.close()

    # Plot 4
    g = sns.catplot(data=df2, x="pulsatility_red", y="mouse", kind="strip",
                    row="state",
                    height=3, aspect=4)
    g.tight_layout()
    # plt.show()
    path_out = os.getcwd()
    path_out = os.path.join(path_out, "../Plot/Linescan Pulsatility in Sleep/Red strip per mouse %s" % vessel_type)
    path_out = os.path.abspath(path_out)
    os.makedirs(os.path.dirname(path_out), exist_ok=True)
    plt.savefig(path_out + ".pdf")
    plt.close()

print("Finished")


import plotly.express as px
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
import plotly.graph_objects as go


# # Read CSV file with space as delimiter and two columns: Power and Date+Time combined as string

df = pd.read_csv("test.csv", sep=r"\s+", names=["Power(watts)", "Date", "Time"], skiprows=1)
df["DateTime"] = df.apply(lambda row: datetime.strptime(f"{row['Date']} {row['Time']}", "%Y-%m-%d %H:%M:%S"), axis=1)
df = df.drop(columns=["Date", "Time"])

df2 = pd.read_csv("test2.csv", sep=r"\s+", names=["Power(watts)", "Date", "Time"], skiprows=1)
df2["DateTime"] = df2.apply(lambda row: datetime.strptime(f"{row['Date']} {row['Time']}", "%Y-%m-%d %H:%M:%S"), axis=1)
df2 = df2.drop(columns=["Date", "Time"])

# Create the plot
plt.plot(df["DateTime"], df["Power(watts)"], marker='o', linestyle='-', linewidth=2, markersize=6)
plt.plot(df2["DateTime"], df2["Power(watts)"], marker='+', linestyle='-', linewidth=2, markersize=6)

# Add labels and title
plt.xlabel("DateTime", fontsize=12)
plt.ylabel("Power (watts)", fontsize=12)
plt.title("Power over Time", fontsize=14, fontweight='bold')

# Rotate x-axis labels for better readability
plt.xticks(rotation=45, ha='right')

plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()


import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
import plotly.graph_objects as go



df = pd.read_csv("test2.csv")
df['Timestamp'] = pd.to_datetime(df['Timestamp'])
column_names = list(df.columns)

for col in column_names:
    if col != 'Timestamp':
        # Extract number with decimals and convert to float
        df[col] = df[col].str.extract(r'(\d+\.\d+|\d+)').astype(float)
        # Plot the column
        plt.plot(df["Timestamp"], df[col], marker='o', linestyle='-', linewidth=2, markersize=6, label=col)

plt.xlabel("DateTime", fontsize=12)
plt.ylabel("Value", fontsize=12)
plt.title("All Columns over Time", fontsize=14, fontweight='bold')
plt.legend()
plt.xticks(rotation=45, ha='right')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

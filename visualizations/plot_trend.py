# ====================================================================
# BUFFALO URBAN FORESTRY ANALYTICS: VISUALIZATION ENGINE
# Coursework: CSCI 343 - Database Management Systems (UNC Asheville)
# Target Platform: Python 3.x / Pandas / Seaborn / Matplotlib
# Implementation: Variance Mapping & Linear Regression Modeling
# ====================================================================

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def generate_regression_plot(csv_path="species_averages.csv", output_path="species_size_vs_benefits_regression.png"):
    """
    Ingests aggregate tree species metrics exported from the database layer
    and executes a linear regression visualization mapping physical trunk scale
    against absolute environmental dollar yields.
    """
    try:
        # 1. Ingest structured dataset generated via the SQL query engine
        df = pd.read_csv(csv_path)
        
        # 2. Establish a minimalist, high-contrast scientific layout grid
        sns.set_theme(style="whitegrid")
        plt.figure(figsize=(10, 6))
        
        # 3. Plot species coordinates and compute linear trend lines
        # The shaded band programmatically maps the 95% statistical confidence interval
        sns.regplot(
            data=df, 
            x="avg_dbh_inches", 
            y="avg_yearly_benefits_usd", 
            color="darkslateblue",
            scatter_kws={'alpha': 0.6, 's': 60}, 
            line_kws={'color': 'crimson', 'linewidth': 2}
        )
        
        # 4. Enforce clear, descriptive typographic labels for professional review
        plt.title("Variance Mapping: Average Tree Species Size vs. Ecosystem Yield", fontsize=12, pad=15)
        plt.xlabel("Average Diameter at Breast Height (DBH) in Inches", fontsize=10)
        plt.ylabel("Average Total Yearly Ecosystem Benefits ($ USD)", fontsize=10)
        
        # 5. Clean layout boundaries and compile the high-resolution portfolio asset
        plt.tight_layout()
        plt.savefig(output_path, dpi=300)
        print(f"[SUCCESS] High-resolution visualization compiled and saved to: {output_path}")
        
    except FileNotFoundError:
        print(f"[ERROR] Target dataset '{csv_path}' not detected. Ensure the SQL aggregation export is available.")
    except Exception as e:
        print(f"[ERROR] Pipeline compilation failure: {str(e)}")

if __name__ == "__main__":
    # Execute the visualization engine pipeline
    generate_regression_plot()

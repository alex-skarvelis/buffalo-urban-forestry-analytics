# Buffalo Urban Forestry Analytics: Taxonomic Normalization and Lifecycle Optimization

---

## Project Overview
This repository contains a multi-stage data-cleaning matrix, taxonomic distribution framework, and lifecycle eco-efficiency assessment analyzing municipal street tree assets. The project handles uncurated civic data arrays natively in PostgreSQL and models structural linear trends using Python's Seaborn library.

---

## Methodological Core Findings

### 1. Mathematical Species Distribution (Question 1)
By executing string assertions to isolate strict biological species boundaries, the pipeline identified **198 unique tree species** across the municipal inventory. The mathematical distribution of the whole population is highly right-skewed, dominated by primary canopy variations:

| Rank | Taxonomic Tree Species | Population Percentage (%) |
| :--- | :--- | :--- |
| 1 | *Acer Platanoides* (Norway Maple) | **18.540%** |
| 2 | *Tilia Cordata* (Littleleaf Linden) | **12.994%** |
| 3 | *Acer Saccharinum* (Silver Maple) | **6.457%** |
| 4 | *Acer Rubrum* (Red Maple) | **3.954%** |
| 5 | *Acer Campestre* (Field Maple) | **3.566%** |
| 6 | *Syringa Reticulata* (Japanese Tree Lilac) | **3.348%** |
| 7 | *Platanus X Acerifolia* (London Planetree) | **3.014%** |
| ... | *[Truncated for Overview]* | ... |
| 113 | *Maclura Pomnifera* (Osage Orange) | **0.058%** |
| ... | *[Truncated for Overview]* | ... |
| 198 | *Fraxinus Nigra* (Black Ash) | **0.002%** |

*Note: Hybrid species containing an embedded `X` cross-breeding token (e.g., Platanus X Acerifolia) were intentionally preserved as standalone rows to track distinct ecological variants, while broad fallback identifiers (spp., species) and cultivars wrapped in single quotes were systematically purged.*

### 2. Life-Cycle Eco-Efficiency (Question 2)
To identify top-performing tree classifications independent of physical size bias, an **Automated Lifecycle Efficiency Ratio** was modeled across individual records. This calculation neutralizes maturity inflation (where older trees artificially dominate absolute values) by dividing a tree's real-time ecosystem yield by its exact trunk size (DBH) prior to aggregate averaging: `Lifecycle Efficiency = Total Yearly Eco Benefits / DBH (Inches)`.

The analytics pipeline isolated distinct investment tiers to provide a transparent decision matrix based on localized database density:
* **High-Yield Specialty Cohort (Top Absolute Efficiency):** *Fagus Grandifolia* and *Maclura pomnifera* (Osage Orange) delivered the highest absolute lifecycle returns, sitting at **\$26.53** and **\$26.26** per inch respectively. However, their smaller sample counts (1 and 14 observations) introduce variance unpredictability.
* **Robust Established Cohort (Scale-Reliable Performance):** For high-density, proven urban stability, top-performing species with widespread regional data baselines settled at Ranks #3 and #4: *Zelkova Serrata* (Sample Size: 669 | **\$21.43/in**) and *Gymnocladus Dioicus* (Sample Size: 840 | **\$20.50/in**).

### 3. Categorical Variance & Size Explanation (Question 3)
Using PostgreSQL's native linear regression model engine (`REGR_R2`), individual tree size was correlated against total ecosystem value within specific species blocks. To prevent dataset fragmentation while preserving absolute mathematical accuracy, single-tree records were retained by wrapping standard deviation calculations in a `COALESCE` handler to map undefined null outcomes to a clean numeric zero:

| Taxonomic Tree Species | Sample Size (n) | Average Benefits (\$) | Std Dev (\$) | Size Explanation (R² %) |
| :--- | :--- | :--- | :--- | :--- |
| *Prunus X Yedoensis* | 8 | \$32.18 | \$5.53 | **100.00%** |
| *Betula Platyphylla* | 6 | \$79.04 | \$10.54 | **100.00%** |
| *Taxodium Distichum* | 24 | \$124.94 | \$58.47 | **97.05%** |
| *Acer X Freemanii* | 877 | \$109.33 | \$79.58 | **96.56%** |
| *Ulmus Americana* | 318 | \$189.43 | \$108.88 | **96.55%** |
| *Acer Platanoides* | 11,678 | \$127.39 | \$64.91 | **85.59%** |
| *Maclura pomnifera* | 14 | \$85.37 | \$9.85 | **82.26%** |
| *Zelkova Serrata* | 669 | \$121.02 | \$43.78 | **82.08%** |
| *Tilia Cordata* | 8,182 | \$105.55 | \$16.81 | **27.33%** |
| *Pinus Rigida* | 6 | \$30.36 | \$0.71 | **0.00%** |
| *Amelanchier Alnifolia* | 1 | \$19.81 | \$0.00 | **0.00%** |

### 4. Genus-Level Property Valuations (Question 4)
When aggregated to the broader taxonomic Genus level by extracting the initial text token from the strings, the pipeline successfully grouped distributed species pools while enforcing data availability thresholds. The top three property-benefit-yielding genera were isolated as:
1. **Carya** (Sample Size: 85 | Average Property Benefit: **\$103.76** | Std Dev: \$22.75)
2. **Pyrus** (Sample Size: 1,339 | Average Property Benefit: **\$103.26** | Std Dev: \$46.55)
3. **Ulmus** (Sample Size: 3,562 | Average Property Benefit: **\$97.78** | Std Dev: \$28.01)

---

## Architectural Data Engineering Challenges & System Design

Civic open-data arrays are highly fragmented. The following defensive processing layers were written natively inside **PostgreSQL** common table expressions (CTEs) to isolate valid biological populations:

### 1. Dynamic Biometric Boundary Boxing
* **The Problem:** Handled severe data logging noise, including negative numbers, zero-inch trunk metrics, and arbitrary data-cap placeholder flags (such as hardcoded `99` entries representing unheard-of 8-foot wide street trees) that heavily skewed statistical distributions.
* **The Engineering Fix:** Implemented a structural biometric bounding block constraining active rows strictly to `dbh > 2` and `dbh <= 75`. This isolated living, operational assets and dropped nursery saplings or corrupt entries.

### 2. Taxonomic Character Consolidation
* **The Problem:** The underlying text strings were cluttered with aesthetic cultivar classifications (enclosed in single quotes), duplicate casing noise, trailing hybrid placeholders (`X`), and generic fallback markers (`spp.`), which artificially fragmented the statistical populations.
* **The Engineering Fix:** Engineered a text-parsing loop combining whitespace-collapsing regular expressions with single-quote string splits (`SPLIT_PART(raw_name, '''', 1)`) nested inside an `INITCAP()` standardizer. This collapsed distinct aesthetic variants back into unified biological parent lines, preventing regression model fragmentation.

```sql
CASE 
    WHEN raw_name LIKE '%''%' THEN TRIM(SPLIT_PART(raw_name, '''', 1))
    ELSE raw_name
END AS cleaned_name
```

### 3. Latent Inventory Valuation Remediations
* **The Problem:** Field-survey data logs tracking dead assets or stump removals (e.g., rows flagged as `STANDING BUTT`) retained legacy economic valuations within the system, threatening to form a false "Standing" botanical genus.
* **The Engineering Fix:** Instituted hardcoded string exclusion lists paired with a dedicated positive utility check (`property_benefits > 0`) to purge dead remnants from the staging layer before data parsing occurred, ensuring only valid biological taxonomy reached the aggregate calculations.

---

## Multi-Tool Integration: Python Linear Regression Modeling

To fulfill the stakeholder requirement to visualize how much physical maturity accounts for environmental yield variance, the aggregate SQL metrics were exported as a structured dataset and mapped inside a Python runtime script.

Using the **Seaborn** library, the system plots individual species averages and deploys a linear regression engine (`sns.regplot`) to evaluate the coefficient of determination (R²) alongside a 95% statistical confidence window:

```python
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Load aggregate output from SQL engine
df = pd.read_csv("species_averages.csv")
sns.set_theme(style="whitegrid")
plt.figure(figsize=(10, 6))

# Plot species coordinates and compute linear regression trend lines
sns.regplot(
    data=df, x="avg_dbh_inches", y="avg_yearly_benefits_usd", color="darkslateblue",
    scatter_kws={'alpha':0.6, 's':60}, line_kws={'color':'crimson', 'linewidth':2}
)

plt.title("Variance Mapping: Average Tree Species Size vs. Ecosystem Yield")
plt.xlabel("Average Diameter at Breast Height (DBH) in Inches")
plt.ylabel("Average Total Yearly Ecosystem Benefits ($ USD)")
plt.tight_layout()
plt.savefig("species_size_vs_benefits_regression.png", dpi=300)
```

---

## Documented Stakeholder Constraints & Governance

To enforce high data integrity and transparent governance, the codebase operates under explicit parameters refined through direct stakeholder communication loops:

* **Geographic Climate Translation:** The raw inventory tracking parameters originate within the climate region of Buffalo, New York, while the stakeholder's deployment zone is located in **Asheville, North Carolina**. Because absolute monetary and volumetric software models (i-Tree Streets) depend on localized growing seasons, hardiness zones, and air pollution indices, a disclaimer is documented noting that regional microclimates may induce minor ranking adjustments among top-tier species.
* **Bessel's Correction Error Handling (Question 3):** To retain rare or low-frequency species populations without throwing database computation loops, standard sample deviation calculations (`STDDEV_SAMP`) tracking sample bounds of n=1 were wrapped in a `COALESCE(..., 0.00)` engine. This gracefully normalizes undefined null outcomes to a clean numeric zero, preserving data grid uniformity.

---

## Academic Context
Developed as an advanced analytics case study for **CSCI 343: Database Management Systems** at UNC Asheville.

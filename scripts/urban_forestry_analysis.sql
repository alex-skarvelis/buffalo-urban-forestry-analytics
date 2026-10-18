-- ====================================================================
-- BUFFALO URBAN FORESTRY ANALYTICS
-- Coursework: CSCI 343 - Database Management Systems (UNC Asheville)
-- Target Platform: PostgreSQL
-- Implementation: Schema Ingestion, Taxonomic Normalization, and Lifecycle Modeling
-- ====================================================================

-- --------------------------------------------------------------------
-- STAGE 1: Schema Definition and Ingestion Setup
-- --------------------------------------------------------------------

CREATE TABLE tree_inventory (
    editing text,                     -- Organization responsible for tree maintenance
    botanical_name text,              -- Specific taxonomic species of the tree asset
    common_name text,                 -- Common name associated with the tree species
    dbh text,                         -- Diameter at breast height measured 4.5 ft above ground level
    total_yearly_eco_benefits text,   -- Cumulative dollar value of multi-vertical environmental yields
    stormwater_benefits text,         -- Dollar value generated via stormwater runoff mitigation
    stormwater_gallons_saved text,   -- Net volume of atmospheric rainfall intercepted (gallons)
    greenhouse_co2_benefits text,     -- Dollar value provided by reduction of greenhouse gases
    co2_avoided text,                 -- Pounds of carbon avoided due to reduced facility energy demands
    co2_sequestered text,             -- Pounds of carbon sequestered directly through annual growth
    energy_benefits text,             -- Dollar value conserved via structural microclimate modifications
    kwh_saved text,                   -- Kilowatt-hours of electricity saved by localized shading
    therms_saved text,                -- Therms of heat energy saved by lowering wind velocity
    air_quality_benefits text,        -- Dollar value of airborne pollutant interception
    pollutants_saved text,            -- Pounds of particulate matter extracted from the atmosphere
    property_benefits text,           -- Aesthetic and localized real estate market value yield ($)
    leaf_surface_area text,           -- Total calculated leaf surface area (sq. ft)
    address text,                     -- Local building number location anchor
    street text,                      -- Public right-of-way street identifier
    side text,                        -- Relative parcel placement metric
    site text,                        -- Designated index tracking multiple trees at a single location
    council_district text,            -- Municipal district jurisdiction locator
    park_name text,                   -- Targeted municipal park identifier, 0 for standard street assets
    latitude text,                    -- Geospatial coordinate dimension
    longitude text,                   -- Geospatial coordinate dimension
    site_ID text,                     -- Unique system location site key
    location_degrees text,            -- Formatted geographic position tracking degree markers
    location_point text               -- Native spatial datatype anchor point()
);


-- --------------------------------------------------------------------
-- STAGE 2: Data-Type Transformations and Regular Expression Scrubbing
-- --------------------------------------------------------------------

-- Strip out currency strings ($) and formatting commas (,) before casting fields to DOUBLE PRECISION
ALTER TABLE tree_inventory 
  ALTER COLUMN total_yearly_eco_benefits TYPE DOUBLE PRECISION USING CAST(regexp_replace(total_yearly_eco_benefits, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN stormwater_benefits TYPE DOUBLE PRECISION USING CAST(regexp_replace(stormwater_benefits, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN stormwater_gallons_saved TYPE DOUBLE PRECISION USING CAST(regexp_replace(stormwater_gallons_saved, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN greenhouse_co2_benefits TYPE DOUBLE PRECISION USING CAST(regexp_replace(greenhouse_co2_benefits, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN co2_avoided TYPE DOUBLE PRECISION USING CAST(regexp_replace(co2_avoided, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN co2_sequestered TYPE DOUBLE PRECISION USING CAST(regexp_replace(co2_sequestered, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN energy_benefits TYPE DOUBLE PRECISION USING CAST(regexp_replace(energy_benefits, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN kwh_saved TYPE DOUBLE PRECISION USING CAST(regexp_replace(kwh_saved, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN therms_saved TYPE DOUBLE PRECISION USING CAST(regexp_replace(therms_saved, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN air_quality_benefits TYPE DOUBLE PRECISION USING CAST(regexp_replace(air_quality_benefits, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN pollutants_saved TYPE DOUBLE PRECISION USING CAST(regexp_replace(pollutants_saved , '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN property_benefits TYPE DOUBLE PRECISION USING CAST(regexp_replace(property_benefits, '[$,]', '', 'g') AS DOUBLE PRECISION),
  ALTER COLUMN leaf_surface_area TYPE DOUBLE PRECISION USING CAST(regexp_replace(leaf_surface_area, '[$,]', '', 'g') AS DOUBLE PRECISION);

-- Alter primary biometric sizing vector from string text block to a compute-ready numerical type
ALTER TABLE tree_inventory 
  ALTER COLUMN dbh TYPE DOUBLE PRECISION USING CAST(dbh AS DOUBLE PRECISION);


-- --------------------------------------------------------------------
-- STAGE 3: Analytical Execution Run Blocks
-- --------------------------------------------------------------------

-- Query 1: Mathematical Species Distribution Profiles (Question 1)
WITH base_filtered AS (
    SELECT 
        -- Compress multi-space text alignments into uniform single spaces
        REGEXP_REPLACE(TRIM(botanical_name), '\s+', ' ', 'g') AS raw_name
    FROM tree_inventory
    WHERE botanical_name IS NOT NULL 
      AND TRIM(botanical_name) != ''
      -- Purge non-botanical survey notation strings, vacancies, and numeric system noise
      AND UPPER(TRIM(botanical_name)) NOT IN (
          'VACANT', 'UNSUITABLE VACANT', 'UNKNOWN TREE', 'UNKNOWN SHRUB', 
          'STUMP OBSTRUCTED', 'STUMP', 'STANDING BUTT', '*CALLS', 
          '448', '445', '444', '443', '0'
      )
),
strip_cultivars AS (
    SELECT 
        CASE 
            -- Extract parent species parameters by truncating cultivar suffixes wrapped in single quotes
            WHEN raw_name LIKE '%''%' THEN TRIM(SPLIT_PART(raw_name, '''', 1))
            ELSE raw_name
        END AS cleaned_name
    FROM base_filtered
),
strict_species_only AS (
    SELECT 
        INITCAP(TRIM(cleaned_name)) AS tree_species
    FROM strip_cultivars
    WHERE 
      -- Eliminate isolated solo genus strings lacking a distinct species designation space
      cleaned_name LIKE '% %'
      -- Exclude rows terminating in broad unknown descriptors (spp., species)
      AND cleaned_name !~* ' (spp|species|sp)\.?$'
      -- Purge records with dead-end trailing hybrid cross elements lacking a matching epithet
      AND cleaned_name !~* ' x\.?$'
),
species_counts AS (
    SELECT 
        tree_species,
        COUNT(*) AS total_count
    FROM strict_species_only
    GROUP BY tree_species
)
SELECT 
    tree_species,
    ROUND(
        (total_count * 100.0) / SUM(total_count) OVER(), 
        3
    ) AS percentage_of_whole
FROM species_counts
ORDER BY percentage_of_whole DESC;


-- Query 2: Size-Independent Lifecycle Eco-Efficiency Evaluation (Question 2)
WITH base_filtered AS (
    SELECT 
        REGEXP_REPLACE(TRIM(botanical_name), '\s+', ' ', 'g') AS raw_name,
        dbh,
        total_yearly_eco_benefits
    FROM tree_inventory
    WHERE botanical_name IS NOT NULL 
        AND TRIM(botanical_name) != ''
        -- Ensure data utility by isolating positive benefit returns
        AND total_yearly_eco_benefits > 0
        -- Apply biometric bounding thresholds approved by stakeholder to flush out outliers
        AND dbh >= 2 
        AND dbh <= 75
),
strip_cultivars AS (
    SELECT 
        CASE 
            WHEN raw_name LIKE '%''%' THEN TRIM(SPLIT_PART(raw_name, '''', 1))
            ELSE raw_name
        END AS cleaned_name,
        dbh,
        total_yearly_eco_benefits
    FROM base_filtered
),
strict_species_only AS (
    SELECT 
        INITCAP(TRIM(cleaned_name)) AS tree_species,
        dbh,
        total_yearly_eco_benefits
    FROM strip_cultivars
    WHERE 
      cleaned_name LIKE '% %'
      AND cleaned_name !~* ' (spp|species|sp)\.?$'
      AND cleaned_name !~* ' x\.?$'
)
SELECT
    tree_species,
    COUNT(*) AS sample_size,
    ROUND(AVG(dbh)::numeric, 2) AS avg_dbh_inches,
    ROUND(AVG(total_yearly_eco_benefits)::numeric, 2) AS avg_yearly_benefits_usd,
    -- Core Metric: Divides real-time metrics per line to analyze true mean efficiency across sizes
    ROUND(AVG(total_yearly_eco_benefits / dbh)::numeric, 2) AS lifecycle_efficiency_usd_per_inch
FROM strict_species_only
GROUP BY tree_species
ORDER BY lifecycle_efficiency_usd_per_inch DESC
LIMIT 10;


-- Query 3: Categorical Variance and Model Explanation Analysis (Question 3)
WITH base_filtered AS (
    SELECT 
        REGEXP_REPLACE(TRIM(botanical_name), '\s+', ' ', 'g') AS raw_name,
        dbh,
        total_yearly_eco_benefits
    FROM tree_inventory
    WHERE botanical_name IS NOT NULL 
      AND TRIM(botanical_name) != ''
      AND total_yearly_eco_benefits > 0
      AND UPPER(TRIM(botanical_name)) NOT IN (
          'VACANT', 'UNSUITABLE VACANT', 'UNKNOWN TREE', 'UNKNOWN SHRUB', 
          'STUMP OBSTRUCTED', 'STUMP', 'STANDING BUTT', '*CALLS', 
          '448', '445', '444', '443', '0'
      )
      AND dbh >= 2 
      AND dbh <= 75
),
strip_cultivars AS (
    SELECT 
        CASE 
            WHEN raw_name LIKE '%''%' THEN TRIM(SPLIT_PART(raw_name, '''', 1))
            ELSE raw_name
        END AS cleaned_name,
        dbh,
        total_yearly_eco_benefits
    FROM base_filtered
),
strict_species_only AS (
    SELECT 
        INITCAP(TRIM(cleaned_name)) AS tree_species,
        dbh,
        total_yearly_eco_benefits
    FROM strip_cultivars
    WHERE 
      cleaned_name LIKE '% %'
      AND cleaned_name !~* ' (spp|species|sp)\.?$'
      AND cleaned_name !~* ' x\.?$'
)
SELECT 
    tree_species,
    COUNT(*) AS sample_size,
    ROUND(AVG(total_yearly_eco_benefits)::numeric, 2) AS avg_benefits_usd,
    -- Secure low-sample records from division errors by mapping undefined outputs to 0.00
    ROUND(
        COALESCE(STDDEV_SAMP(total_yearly_eco_benefits)::numeric, 0.00),
        2
        ) AS std_dev_benefits_usd,
    -- Native linear regression engine mapping the correlation coefficient percentage
    ROUND(
        COALESCE(REGR_R2(total_yearly_eco_benefits, dbh)::NUMERIC, 0) * 100.0, 
        2
    ) AS species_size_explanation_percentage
    FROM strict_species_only
GROUP BY tree_species
ORDER BY species_size_explanation_percentage DESC, sample_size DESC;


-- Query 4: Genus-Tier Property Valuation Yields (Question 4)
WITH base_filtered AS (
    SELECT
        -- Isolate plant Genus by extracting the primary token before the initial space delimiter
        INITCAP(TRIM(SPLIT_PART(REGEXP_REPLACE(TRIM(botanical_name), '\s+', ' ', 'g'), ' ', 1))) AS tree_genus,
        dbh,
        property_benefits 
    FROM tree_inventory
    WHERE botanical_name IS NOT NULL 
      AND TRIM(botanical_name) != ''
      AND UPPER(TRIM(botanical_name)) NOT IN (
          'VACANT', 'UNSUITABLE VACANT', 'UNKNOWN TREE', 'UNKNOWN SHRUB', 
          'STUMP OBSTRUCTED', 'STUMP', 'STANDING BUTT', '*CALLS', 
          '448', '445', '444', '443', '0'
      )
      AND property_benefits > 0
      AND dbh > 2 
      AND dbh <= 75
)
SELECT 
    tree_genus,
    COUNT(*) AS sample_size,
    ROUND(AVG(property_benefits)::numeric, 2) AS avg_property_benefits_usd,
    ROUND(STDDEV_SAMP(property_benefits)::numeric, 2) AS std_dev_property_benefits_usd
FROM base_filtered
GROUP BY tree_genus
ORDER BY avg_property_benefits_usd DESC
;

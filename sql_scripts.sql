--Views
SELECT * FROM "CHR3" LIMIT 10;
SELECT * FROM "FARA3" LIMIT 10;
-----------------------------------------------------------------------

-- 1. First create cleaned tables
CREATE TABLE fara_clean AS
SELECT 
    LOWER(TRIM(State)) AS state_clean,
    LOWER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        County,
        'County', ''),
        'Parish', ''),
        'Borough', ''),
        'Municipality', ''),
        'Census Area', '')
    )) AS county_clean,
    *
FROM FARA3;
------------------------------------------------------------------------------

-- Clean the CHR3 table
CREATE TABLE chr_clean AS
SELECT 
    LOWER(TRIM(State)) AS state_clean,
    LOWER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        County,
        ' County', ''),
        ' Parish', ''),
        ' Borough', ''),
        ' Municipality', ''),
        ' Census Area', '')
    )) AS county_clean,
    *
FROM CHR3;

-----------------------------------------------

SELECT * 
FROM "fara_clean"
LIMIT 10;
------------------------------------------------------------------------------


------------------------------------------------------------------------

-- Create table of exact matches
CREATE TABLE exact_matches2 AS
SELECT 
    f.*,
    c.*,

    'exact' AS match_type
FROM fara_clean f
JOIN chr_clean c ON 
    f.state_clean = c.state_clean AND 
    f.county_clean = c.county_clean;
    
--------------------------------
SELECT * FROM "exact_matches2";
------------------
-- DRop COLUMN
ALTER TABLE exact_matches2 DROP COLUMN match_type;
ALTER TABLE exact_matches2 DROP COLUMN state_clean;
ALTER TABLE exact_matches2 DROP COLUMN county_clean;
ALTER TABLE exact_matches2 DROP COLUMN "state_clean:1";
ALTER TABLE exact_matches2 DROP COLUMN "county_clean:1";
ALTER TABLE exact_matches2 DROP COLUMN "State:1";
ALTER TABLE exact_matches2 DROP COLUMN "County:1";
-------------------------------------------------------

------------------------View-----------------------
SELECT * FROM "CHR3" LIMIT 10;
SELECT * FROM "exact_matches2"
LIMIT 10;
---------------------------------Cols names
PRAGMA table_info(exact_matches2);

-----------------------------------
SELECT State, County, poor_health 
FROM "exact_matches"
WHERE poor_health IS NULL
GROUP BY County
------------------


SELECT * FROM "CHR3";

--------------------------------------------
----------------------------------------------------------------------------------------

-- Create table of unmatched FARA records
CREATE TABLE fara_unmatched AS
SELECT f.*
FROM fara_clean f
LEFT JOIN exact_matches2 e ON 
    f.state_clean = e.state_clean AND 
    f.county_clean = e.county_clean
WHERE e.state_clean IS NULL;

------------------------------
SELECT * FROM "fara_unmatched";
---------------------------------------
SELECT state_clean AS State, county_clean County, COUNT(county_clean) AS freq
FROM "fara_unmatched"
GROUP BY county_clean
ORDER BY freq DESC


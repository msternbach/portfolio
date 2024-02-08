
-- How often was zone and man run in 2023 and 2022?

SELECT tot_db, ROUND((man_per_db/tot_db),4) AS man_percent,
ROUND((zone_per_db/tot_db),4) AS zone_percent
FROM
(SELECT SUM(db) AS tot_db, SUM((db*man)) AS man_per_db,
SUM((db*zone)) AS zone_per_db
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022))

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- What about per week?

SELECT week, season, tot_db, ROUND((man_per_db/tot_db),4) AS man_percent,
ROUND((zone_per_db/tot_db),4) AS zone_percent
FROM
(SELECT week, season, SUM(db) AS tot_db, SUM((db*man)) AS man_per_db,
SUM((db*zone)) AS zone_per_db
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY week, season
ORDER BY week)
ORDER BY man_percent DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--What was the most run coverage in 2023 and 2022?

SELECT season, SUM(db) AS tot_db, AVG(cover0) AS cover0_per_db,
AVG(cover1) AS cover1_per_db, AVG(cover2) AS cover2_per_db,
AVG(cover2man) AS cover2man_per_db, AVG(cover3) AS cover3_per_db,
AVG(cover4) AS cover4_per_db, AVG(cover6) AS cover6_per_db
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY season

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- For each coverage type which team had the highest percentage? The least?

SELECT name, season, SUM(db) AS tot_db, SUM((db*cover0)) AS cover0_per_db,
SUM((db*cover1)) AS cover1_per_db, SUM((db*cover2)) AS cover2_per_db,
SUM((db*cover2man)) AS cover2man_per_db, SUM((db*cover3)) AS cover3_per_db,
SUM((db*cover4)) AS cover4_per_db, SUM((db*cover6)) AS cover6_per_db
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY name, season
ORDER BY cover0_percent DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

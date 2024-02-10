
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

SELECT season, SUM(db) AS tot_db, AVG(cover0) AS cover0_percent,
AVG(cover1) AS cover1_percent, AVG(cover2) AS cover2_percent,
AVG(cover2man) AS cover2man_percent, AVG(cover3) AS cover3_percent,
AVG(cover4) AS cover4_percent, AVG(cover6) AS cover6_percent
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY season

-- Cover 3 was run the most by far with it being called about 32% of the time in both 2022 and 2023
-- Cover2man was run the least with it being called about only 1.7% in both seasons

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- For each coverage type which team had the highest percentage? The least?

SELECT name, season, SUM(db) AS tot_db, ROUND(AVG(cover0),4) AS cover0_percent,
ROUND(AVG(cover1),4) AS cover1_percent, ROUND(AVG(cover2),4) AS cover2_percent,
ROUND(AVG(cover2man),4) AS cover2man_percent, ROUND(AVG(cover3),4) AS cover3_percent,
ROUND(AVG(cover4),4) AS cover4_percent, ROUND(AVG(cover6),4) AS cover6_percent
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY name, season
ORDER BY cover0_percent DESC;

/*
Cover 0:
The Eagles had the highest percentage of cover 0 ran against them in 2023 at 7.22%. The Colts in 2022 had the least at 1.02%.
It seems that teams with more mobile quarterbacks faced more cover 0, as the Eagles, Bills, Ravens, and Bearss led.
Cover 1:
The 2023 New England had the highest percentage with 29.04%, the 2022 Chiefs had the second most at 28.91%. The 2023 bucs 
and Dolphins had the least. 
Cover 2:
The 2022 Bengals had the highest percentage with 23.20%, there was a large gap between them and second, the 2022 Dolphins
had the second most at 19.45%. The 2023 and 2022 Ravens had the least at 7.90% and 4.23% respectively.
Cover 2man:
The 2023 Dolphins had cover2man run against them the most at 5.71%. The 2023 Ravens had the least at 0.16%
Cover 3:
Cover 3 was the most ran coverage. The 2022 Panthers had run against them 44.34% almost half of the time. 
The 2022 Vikings had it run against them at 20.47% for the lowest.
Cover 4:
The 2023 Eagles had it run against them the most at 23%. The 2022 49ers had it run against them the least at 7.55%
Cover 6:
The 2023 Titans had it run against them the most at 14.52%. The 2022 Texans had it the least at just 4.22%
*/



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

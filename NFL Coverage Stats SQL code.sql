
-- How often was zone and man run in 2023 and 2022?

SELECT season, SUM(db) AS tot_db, AVG(man) AS man_avg,
AVG(zone) AS zone_avg
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY season

-- Man was run 24.9% in 2023 and 25.1% in 2022
-- Zone was run 70.5% in 2023 and 68.5% in 2022

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- What about per week?

SELECT week, season, ROUND(SUM(db),2) AS tot_db, ROUND(AVG(man),2) AS man_percent,
ROUND(AVG(zone),2) AS zone_percent
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY week, season
ORDER BY man_percent DESC;

-- Zone and man were run pretty consistently week by week with zone ranging from 60-73% and man from 22-31%
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
The Eagles had the highest percentage of cover 0 ran against them on average in 2023 at 7.22%. The Colts in 2022 had the least at 1.02%.
It seems that teams with more mobile quarterbacks faced more cover 0, as the Eagles, Bills, Ravens, and Bearss led.
Cover 1:
The 2023 New England had the highest average percentage with 29.04%, the 2022 Chiefs had the second most at 28.91%. The 2023 bucs 
and Dolphins had the least. 
Cover 2:
The 2022 Bengals had the highest percentage of cover 2 23.20%, there was a large gap between them and second, the 2022 Dolphins
had the second most at 19.45%. The 2023 and 2022 Ravens had the least at 7.90% and 4.23% respectively.
Cover 2man:
The 2023 Dolphins had cover2man run against them the most at 5.71%. The 2023 Ravens had the least at 0.16%
Cover 3:
The 2022 Panthers had cover 3 run against them 44.34% almost half of the time. The 2022 Vikings had it run against them
at 20.47% for the lowest.
Cover 4:
The 2023 Eagles had cover 4 run against them the most at 23% on average. The 2022 49ers had it run against them the least at 7.55%
Cover 6:
The 2023 Titans had cover 6 run against them the most at 14.52% on avrage. The 2022 Texans had it the least at just 4.22%
*/

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- top 25 percentile for each coverage (I needed to find this in order to do the next step):

SELECT
  SUM(db) AS tot_db,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover0) AS cover0_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover1) AS cover1_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover2) AS cover2_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover2man) AS cover2man_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover3) AS cover3_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover4) AS cover4_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover6) AS cover6_Q4
FROM
  (SELECT * FROM coveragestats2023
   UNION
   SELECT * FROM coveragestats2022);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- When qbs played games where they faced coverages more than normal (top 25 percentile) did they do better or worse than their overall average output?

with playerstats AS (SELECT player_name, position, recent_team, season, week,
					 passing_yards, attempts, passing_tds, 
					 interceptions, passing_epa, fantasy_points
					 FROM stats2022
					 WHERE position = 'QB'
					 UNION 
					 SELECT player_name, position, recent_team, season, week,
					 passing_yards, attempts, passing_tds, 
					 interceptions, passing_epa, fantasy_points
					 FROM stats2023
					 WHERE position = 'QB'),
					 
coveragestats AS (SELECT *
				  FROM coveragestats2022
				  UNION
				  SELECT *
				  FROM coveragestats2023
),

cover0_stats AS (SELECT player_name, ROUND(SUM(db),2) AS cov0_dropbacks,
			ROUND(AVG(passing_yards),2) AS cov0_avg_yards, 
			ROUND(AVG(passing_tds),2) AS cov0_avg_tds,
			ROUND(AVG(interceptions),2) AS cov0_avg_ints,
			ROUND(AVG(passing_epa),2) AS cov0_avg_epa,
			ROUND(AVG(fantasy_points),2) AS cov0_avg_fantasy_points
			FROM playerstats
			INNER JOIN coveragestats
			ON playerstats.recent_team = coveragestats.name AND
			playerstats.week = coveragestats.week AND 
			playerstats.season = coveragestats.season
			WHERE attempts > 10 AND cover0 > .08
			GROUP BY player_name
			HAVING SUM(db) > 100),

total_averages AS (SELECT player_name, ROUND(SUM(db),2) AS total_dropbacks,
	   		ROUND(AVG(passing_yards),2) AS avg_yards, ROUND(AVG(passing_tds),2) AS avg_tds,
	   		ROUND(AVG(interceptions),2) AS avg_ints, ROUND(AVG(passing_epa),2) AS avg_epa,
	   		ROUND(AVG(fantasy_points),2) AS avg_fantasy_points
			FROM playerstats
			INNER JOIN coveragestats
			ON playerstats.recent_team = coveragestats.name AND
			playerstats.week = coveragestats.week AND 
			playerstats.season = coveragestats.season
			GROUP BY player_name)
			
SELECT cover0_stats.player_name, cov0_dropbacks,total_dropbacks,
cov0_avg_yards, avg_yards, cov0_avg_tds, avg_tds, cov0_avg_ints,
avg_ints, cov0_avg_epa, avg_epa, cov0_avg_fantasy_points, avg_fantasy_points
FROM total_averages
INNER JOIN cover0_stats
ON total_averages.player_name = cover0_stats.player_name

/*
Cover0 - 0.08%:

Most yards
G.Minshew, T.Tagovailoa, and D.Ridder had 50+ more yards
Geno smith and Kirk Cousins had 30 less yards
Most tds
Minshew and Trevor Lawrence had 1 more td on average
Most ints
Stafford and Lawrence had over 0.5 more ints
Passing_epa
Tua had a 9.62 epa boost 
Kirk cousins had a 4.86 decrease
Most fantasy points
Minshew had a 8.77 avg point increase. Only 2 of the 15 qbs had a decrease in average points and it was minimal for both

Cover1 - 28%:

Most yards
Davis Mills had 80+ more yards
Kirk Cousins had 30 less yards
Most tds
Geno Smith had .94 more tds
Andy Dalton had .85 less
Most ints
Passing_epa
Geno and Herbert both had around a 9 point boost. 5 qbs had a 5+ point boost. Purdy and Stafford had a negative 2.7 point decrease
Most fantasy points
Geno and Jordan Love both had 8 point boosts. 8 qbs had 3+ point boosts. Only notable decreases were Mac Jones and Dalton.
Cover2 - 20% :

Most yards
Josh Allen and Burrow had 350+ dropbacks when facing cover 2 20%+ of the time. They had around 30 more yards each. Brissett had 94 more yards. Tua had 27 less yards than average and he had 487 dropbacks.
Most tds
Most ints
Passing_epa
Dak had a 14.97 epa decrease with 113 total dropbacks. Tua had -2.10 with 487 dropbacks. Carr had + 2.24 on over 300 dropbacks
Most fantasy points
Jordan Love had 5.18 point boost on 274 dropbacks. Burrow and Mahomes had 2.31 increase on 300+ dropbacks. Dak had -10.66

Cover3 - 40%:

Most yards
Purdy had 46.84 more yards on 405 dropbacks. Jordan Love had 36 more on 272 dropbacks. Herbert had 31 less on 448 dropbacks
Most tds
Hurts had .74 less on 229 dropbacks
Most ints
Passing_epa
Baker had negative 5.84 on 403 dropbacks. Herbert had negative 3.32 on 448 dropbacks.
Most fantasy points
Purdy had 4.18 more fantasy points. Baker had negative 3.39 and Herbert had negative 2.55

Cover4 - 25%:

Most yards
Geno had 33 less on 311 dropbacks, Josh Allen had 44.07 less on 195 dropbacks. Hurts had 25 more on 369 dropbacks
Most tds
Most ints
Mahomes had 0.64 more ints on 314 dropbacks. Most top qbs had more ints.
Passing_epa
Hurts had a increase of 1.97. Dak had 6.85 less epa, Mahomes had 4.12 less, Allen had 6.13 less
Most fantasy points
Hurts had 4.03 more. Dak had 3.38 less. Jackson had 3.09 less. Tua had 2.89 less. Allen had 3.89 less.



Cover6 - 15%:

Most yards
Most tds
Most ints
Passing_epa
Dak had 6.45 increase on 177 dropbacks. Burrow had a -7.02 on 218 dropbacks. Allen had -3.36 on 253 dropbacks
Most fantasy points
Dak had 4.85 increase. Goff had a 3.10 increase. Burrow had a 4.45 decrease, Allen had a 3.20 decrease.

Any coverage run more than 50%
	Justin Fields had the most dropbacks of 317. He had 919 total dropbacks of past 2 seasons. Trevor had 257. Herbert had 230 and Goff had 207.
	Geno had 2.85+ epa on 169 dropbacks. Justin Fields has +0.52 epa. Lamar had -7.71 and Dak had -6.25 on 115 dropbacks each. Herbert had -5.56, Goff had -4.54, Trevor -4.42
	Purdy had 3.49 increase in fantasy points. Justin Fields had 2.90 increase. Dak had -4.78

Coverage played evenly (at least less then 30% each):
	Trevor had most dropbacks at 465. Tua, Burrow, Kirk, and Allen were all over 300
	Mahomes had +3.44 epa on 270 dropbacks. Herbert had +2.13 on 280, Burrow +1.98 on 403. Purdy had -8.13 on 189 dropbacks
	Kirk had +5.28 on 311 dropbacks. Tom brady had +3.97 on 247 dropbacks, Allen had +3.08. Purdy had -5.94.
/*

















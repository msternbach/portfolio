
-- How often was zone and man run in 2023 and 2022?

SELECT season, SUM(db) AS tot_db, AVG(man) AS man_avg,
AVG(zone) AS zone_avg
FROM
(SELECT * FROM coveragestats2023
UNION
SELECT * FROM coveragestats2022)
GROUP BY season;

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
GROUP BY season;

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
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover3) AS cover3_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover4) AS cover4_Q4,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cover6) AS cover6_Q4
FROM
  (SELECT * FROM coveragestats2023
   UNION
   SELECT * FROM coveragestats2022);

-- Percentiles: Cover 0 - 0.047, Cover 1 - 0.276, Cover 2 - 0.19, Cover 3 - 0.40875, Cover 4 - 0.216, Cover 6 - 0.138

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
			WHERE attempts > 10 AND cover0 > .047
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
			
SELECT cover0_stats.player_name, cov0_dropbacks, total_dropbacks,
cov0_avg_yards, avg_yards, (cov0_avg_yards - avg_yards) AS yard_diff, cov0_avg_tds, 
avg_tds, (cov0_avg_tds - avg_tds) AS tds_diff, cov0_avg_ints, avg_ints,
(cov0_avg_ints - avg_ints) AS ints_diff, cov0_avg_epa, avg_epa,
(cov0_avg_epa - avg_epa) AS epa_diff, cov0_avg_fantasy_points, avg_fantasy_points,
(cov0_avg_fantasy_points - avg_fantasy_points) AS fantasy_points_diff
FROM total_averages
INNER JOIN cover0_stats
ON total_averages.player_name = cover0_stats.player_name
ORDER BY yard_diff;

/*
Cover0 > 4.7%:

When facing cover 0 an increased amount the majority of the players in the list had increased success. Gardner Minshew, Tua Tagovailoa,
Kenny Pickett, Patrick Mahomes, and Kyler Murray stood out as having much higher than normal statistical output. In games when facing
Cover 0 percentages in the top 25th percentile Minshew had a whopping increase of 67.19 more passing yards, 6.29 more fantasy points
and an increased epa of 4.54 on 253 total dropbacks. Kyler Murray had 5.27 more fantasy points, though on just 104 dropbacks, Tua
and Kenny Pickett each had an increased epa of about 8 which is a very impressive difference, and Mahomes had an increased epa of
of 4.5 on 348 dropbacks.

Only one qb stood out as doing much worse in games where he faced cover 0 an increased amount and that was Joe Flacco. Flacco had
an average epa 12.58 points less than his average and had 5.91 less fantasy points despite throwing for 30 more yards than his average.

Cover1 > 27.6%:

Cover 1 was another coverage that quarterbacks seemed to have increased success on. Geno Smith and Justin Herbert had increased epas
of 9.10 and 8.90 respectively and Herbert did it on 293 dropbacks. Also, Geno and Jordan Love each had increased fantasy point outputs
of about 8.

A few qbs such as Mac Jones, Tua, and Andy Dalton did a little worse than their averages but nothing really stood out. Cover 0 and Cover 1
are both man coverages, so then reason that teams run man coverages only about 30% of the time average might be because qbs have overall
increased success against man.

Cover2 > 19% :

Against cover 2 Jacoby Brisett and Baker Mayfield both had increased epas of about 8.30, and Joe Falcco had increased epa of 7.36 although
none of these qbs surpassed 150 total dropbacks against cover 2 when played in the top 25 percentile. Jordan Love had an increased fantasy
points output of 5.44 on 304 dropbacks.

One star quarterback stood out as doing much worse when facing cover 2 an increased amount; Dak Prescott. Dak had a horrendous
epa difference of -15.74 with his average epa of 5.54 going to -10.20. He also had 11.54 less fantasy points and 0.92 interceptions.
It was only on 159 dropbacks but those numbers are so bad that teams start thinking about running cover 2 more against him.

Cover3 > 40.875%:

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


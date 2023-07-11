##########################
##        INTRO         ##
##########################

# Beginning of June 2023 I finalized the Google Data Analyst Professional Certificate and completed a case study (Bike Share) to complete the course.

# In the weeks after I uploaded my case study to GitHub I finished a course on more advance SQL topics and
# passed the exam "Basic Proficiency in KNIME Analytics Platform" (ETL tool). With this new knowledge I decided to revisit the Google case study and do it again from scratch.

# In KNIME created a data pipeline to combine the 12 CSV files provided and performed data cleaning and data manipulation. The data manupulation
# in KNIME allowed me to use the geographical coordinates in the data source to calculate the distance between the pick up
# and drop off of shared-bikes in Chicago. These geographical coordinates were not used at all in my first trial and now became one additional measure
# that we could use to generate data-informed decisions.

# Also very interesting, in the first case study I loaded all 12 files into MySQL directly and the result was the data combined in one-big-table with 1,2 GB.
# Using KNIME I could split the combined CSV files into three tables and really take advantage of the benefits of working with relatational databases. 
# The three tables combined add up to 454 mb, less than 50% of the one-big-table. This I consider a great improvement :)

# In my new repository you find the SQL code writen in MySQL, a Word file where I place the outcome of my queries and also a PowerPoint file where I explain the steps taken in
# KNIME to create the tables used in this analysis.

# I learned a lot and I'm happy I could showcase my new skills in this bike-share_2.0 found here: https://github.com/pcargolo/bike_share_2.0
# The first case study can be found in this other link and it's very satisfying to me to see the improvement: https://github.com/pcargolo/bike-share
# I'm looking forward to what I can further unlock with my next steps in my Data Journey.

##############################
##     THE BUSINESS TASK    ##
##############################

# Understand how casual riders and annual members use Cyclistic bikes differently.
# From these insights, create recommendations for a new marketing strategy to convert casual riders into annual members.

# To tackle this business task (BT), I created a set of questions that will guide my analysis and at the 
# end I will state a summary and my conclusions.

#############################################
## QUESTIONS I ELABORATED TO ANSWER THE BT ##
#############################################

# 1.	What's the percentage split between members and casual users?
# 2.	What is the average duration of a ride in the months considered? Average overall and per user type.
# 3.	What is the average distance between pick up and drop_off? Average overall and per user type.
# 4.	What is the max and min distance of drop_off for each type of user?
# 4a.   How many rides have the pick-up and drop-off location at the same station (drop-off distance = zero)?
# 5.    What are the top 3 drop off distances per user type and their start and end station names?
# 6.	Which season has the highest/lowest number of rides? Average overall and per user type.
# 7.	Which day of the week has the highest/lowest number of rides? Average overall and per user type.
# 8.	What are the top 3 start and end stations? Count per user and display all in in one output.
# 9.	What is the most/least used type of biek? Count overall and per user type.
# 10.	Time of day (all/split)?

###########################
##     DATA ANALYSIS     ##
###########################

#################################################################
# 1.	What's the percentage split between members and casual users?
# From the query below: rides from casual riders correspond to 40,6% of the total, while rides from member 59,4%.

SELECT 
    ru.member_casual,
    -- COUNT(DISTINCT rm.ride_id) AS count,         # I decided to remove this attribute afterwards. Doesn't add value to the analysis
    (COUNT(DISTINCT rm.ride_id) / 
		(SELECT COUNT(DISTINCT ride_id)
        FROM ride_metrics) * 100) AS percentage
FROM
    ride_metrics rm
		JOIN
        ride_usage ru ON ru.usage_id = rm.usage_id
GROUP BY member_casual;


#################################################################
# 2.	What is the average duration of a ride in the months considered? Average overall and per user type.
# From the query below: The overall average is 17min 41sec. The average for casual riders is 24 min 06 sec and for members is 13 min 17 sec.

SELECT
	ru.member_casual,
    SEC_TO_TIME(AVG(rm.duration_sec)) as avg_duration_user,
    a.avg_duration_overall
FROM
	ride_metrics rm
		JOIN
	ride_usage ru ON ru.usage_id = rm.usage_id
		CROSS JOIN
	(SELECT SEC_TO_TIME(AVG(duration_sec)) as avg_duration_overall FROM ride_metrics) a
GROUP BY ru.member_casual, a.avg_duration_overall; -- I added the cross join so that we can see in the same table the avg per user and the avg overall


#################################################################
# 3.	What is the average distance between pick up and drop-off? Average overall and per user type.
# From the query below: The avg drop off distance is nearly the same for the differnt types of users. 2,23 km for casual riders and 2,22 km for members. The overall avg is at 2,22 km.

SELECT 
	ru.member_casual,
    ROUND(AVG(rm.drop_off_distance),2) as avg_drop_off_dist_user,
    ROUND(a.avg_drop_off_distance_overall, 2) as avg_drop_off_dist_overall
FROM ride_metrics rm
		JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
		CROSS JOIN
    (SELECT AVG(drop_off_distance) as avg_drop_off_distance_overall FROM ride_metrics) a
GROUP BY ru.member_casual, avg_drop_off_dist_overall;


#################################################################
# 4.	What is the max and min distance of drop-off for each type of user?
# From the query below: for both types of users the minimum distance is zero. For the maxium distance the casual riders have a higher 
# maximum but not by much at all as the difference is just one meter (9.814 m/9.813 m) The stations will be seen in the result of question 5.

SELECT 
	ru.member_casual,
    MIN(rm.drop_off_distance) AS min_drop_off_distance_user,
    MAX(rm.drop_off_distance) AS max_drop_off_distance_user
FROM ride_metrics rm
		JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
GROUP BY ru.member_casual;

# 4a.	How many rides have the start and drop-off location at the same station (drop-off distance = zero)? Also percentage of total
# From the query below: casual riders have the drop-off station same as the pick-up location twice as much as the members. Still the numbers are quite low at 2,16% and 1,04%.
# I ran this query just out of curiosity based on the result from question 4.

SELECT 
	ru.member_casual,
    COUNT(rm.ride_id) AS count_rides_same_pickup_dropoff,
    a.total_rides,
    ROUND(COUNT(rm.ride_id)/a.total_rides*100, 2) AS percentage
FROM ride_metrics rm
	JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
    CROSS JOIN
    (SELECT COUNT(ride_id) AS total_rides FROM ride_metrics) a
WHERE rm.drop_off_distance = 0
GROUP BY ru.member_casual, a.total_rides
ORDER BY ru.member_casual;


#################################################################
# 5. What are the top 3 drop off distances per user type and their start and end station names?
# From the query below: In the "top 3 table" we see 3 rows for casual riders and 4 rows for members. This is because rank 3 from members has a 
# tie between 'Canal St & Adams St-Wentworth Ave & Cermak Rd*' and 'Canal St & Adams St-Green St & Madison Ave*'. This is why I 
# prefered to use windows functions for this type of analysis (top X).
# Interesting is that the longest distance for casual rides is 'Laflin St & Cullerton St-Green St & Madison Ave*' with 9,814 km and for members
# is 'Aberdeen St & Randolph St-Green St & Madison Ave*' with 9,813 km. Also interesing is that 'Green St & Madison Ave' appers as end for all casual rows and 
# for the first two of members. It seems that it's a popular destination for long rides.

SELECT
	member_casual,
    start_Station_name,
    end_station_name,
    drop_off_distance
FROM
	c  -- temporary table generated from the query below
WHERE rank_distance <= 3; -- At first I tryed running everything in a single query but it took way too long so I did in two steps.
						  -- First I created a temporary table below to store the information in "c". Afterwards I ran this query with "FROM c".

CREATE TEMPORARY TABLE c AS 
(
SELECT
		a.member_casual,
		a.start_Station_name,
		a.end_station_name,
		b.drop_off_distance,
		RANK() OVER (PARTITION BY a.member_casual ORDER BY b.drop_off_distance DESC) AS rank_distance
	FROM
		(SELECT 
			ru.member_casual,
			rs.start_Station_name,
			rs.end_station_name,
			CONCAT(rs.start_Station_name,rs.end_station_name) AS new_id
		FROM ride_metrics rm
				JOIN
			ride_usage ru ON ru.usage_id = rm.usage_id
				JOIN
			ride_stations rs ON rs.stations_id = rm.stations_id
		GROUP BY ru.member_casual, start_Station_name, end_station_name) a
		JOIN
		(SELECT 
			rs.start_Station_name,
			rs.end_station_name,
			drop_off_distance,
			CONCAT(rs.start_Station_name,rs.end_station_name) AS new_id
		FROM ride_metrics rm
				JOIN
			ride_stations rs ON rs.stations_id = rm.stations_id
		GROUP BY start_Station_name, end_station_name, drop_off_distance) b ON b.new_id = a.new_id
	);


#################################################################
# 6.	Which season has the highest/lowest number of rides? Average overall and per user type.
# From the query below: Summer has the highest percentage at 41,8% split in 21,9% for members and 19,9% for casual riders. Fall season comes second at 26,5%,
# then Spring at 22,5% and finally Winter at 9,2%. This is a very nice output to understand in which periof of the year marketing campagnes should spend more efforts/money.

SELECT 
	a.member_casual, 
    a.season,
    a.percentage_user_season,
    SUM(a.percentage_user_season) OVER (PARTITION BY a.season) as percentage_season
FROM (SELECT 
	ru.member_casual,
    CASE 
		WHEN MONTHNAME(rm.started_at) IN ('June', 'July', 'August') THEN 'Summer'
		WHEN MONTHNAME(rm.started_at) IN ('December', 'January', 'February') THEN 'Winter'
		WHEN MONTHNAME(rm.started_at) IN ('March', 'April', 'May') THEN 'Spring'
		WHEN MONTHNAME(rm.started_at) IN ('September', 'October', 'November') THEN 'Fall'
	END AS season,
	COUNT(DISTINCT rm.ride_id)/(SELECT COUNT(DISTINCT ride_id) from ride_metrics)*100 AS percentage_user_season
FROM ride_metrics rm
	JOIN
	ride_usage ru ON ru.usage_id = rm.usage_id
GROUP BY ru.member_casual, season
ORDER BY season, ru.member_casual DESC) a;


#################################################################
# 7.	Which day of the week has the highest/lowest number of rides? Average overall and per user type.
# From the two queries below: we can see that casual riders have the highest percentage on the weekends while members have the highest percentage on business days. 

SELECT 
    ru.member_casual,
    DAYNAME(rm.started_at) AS weekday,
    COUNT(DISTINCT rm.ride_id) / (SELECT 
            COUNT(DISTINCT ride_id)
        FROM
            ride_metrics) * 100 AS percentage_user_weekday
FROM
    ride_metrics rm
        JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
GROUP BY ru.member_casual , DAYNAME(rm.started_at)
ORDER BY ru.member_casual, COUNT(DISTINCT rm.ride_id) DESC;

SELECT *
FROM
(
	SELECT
		*,
		SUM(a.percentage_user_weekday) OVER (PARTITION BY a.weekday) as percentage_weekday
	FROM
		(SELECT 
			ru.member_casual,
			DAYNAME(rm.started_at) AS weekday, 
			COUNT(DISTINCT rm.ride_id)/(SELECT COUNT(DISTINCT ride_id) from ride_metrics)*100 AS percentage_user_weekday
		FROM ride_metrics rm
			JOIN
			ride_usage ru ON ru.usage_id = rm.usage_id
		GROUP BY ru.member_casual, DAYNAME(rm.started_at)
		ORDER BY weekday, COUNT(DISTINCT rm.ride_id) DESC) a
) b
ORDER BY percentage_weekday DESC; -- this query is very similar to the one in the question before but because this view is more crowded
								  -- I added one more layer to it so that I could order by the percentage_weekday


#################################################################
# 8.	What are the top 3 start and end stations? Count per user and display all in in one output.
# From the queries below: very interesting to see the different behaviours of casual riders and members when it comes to pick-up and drop-off locations. 
# All stations in the view are differnt between casual riders and members. This is a good hint if we want to focus the marketing towards casual riders without
# the already members see ads to become members again. 

-- I tried several different ways to the outcome I first had in my mind but after many trials and research I could not find a cleaner way for it. 
-- In the end I created 4 temporary tables with limits of number of rows and used UNION to create the table I wanted. If I needed to use the same table more than 
-- once I would opted for a CTE, as temporary tables can only be called once.

SELECT * FROM start_casual
UNION
SELECT * FROM end_casual
UNION
SELECT * FROM start_member
UNION
SELECT * FROM end_member;

CREATE TEMPORARY TABLE start_casual AS
(SELECT
	ru.member_casual,
    rs.start_station_name as station_name,
    'start' AS station_type,
    COUNT(rm.stations_id) AS count
FROM ride_metrics rm
	JOIN
    ride_stations rs ON rs.stations_id = rm.stations_id
    JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
WHERE ru.member_casual = 'casual'
GROUP BY ru.member_casual, rs.start_station_name
ORDER BY COUNT(rm.stations_id) DESC
LIMIT 3); 

CREATE TEMPORARY TABLE end_casual AS
(SELECT
	ru.member_casual,
    rs.end_station_name as station_name,
    'end' AS station_type,
    COUNT(rm.stations_id) AS count
FROM ride_metrics rm
	JOIN
    ride_stations rs ON rs.stations_id = rm.stations_id
    JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
WHERE ru.member_casual = 'casual'
GROUP BY ru.member_casual, rs.end_station_name
ORDER BY COUNT(rm.stations_id) DESC
LIMIT 3);

CREATE TEMPORARY TABLE start_member AS
(SELECT
	ru.member_casual,
    rs.start_station_name as station_name,
    'start' AS station_type,
    COUNT(rm.stations_id) AS count
FROM ride_metrics rm
	JOIN
    ride_stations rs ON rs.stations_id = rm.stations_id
    JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
WHERE ru.member_casual = 'member'
GROUP BY ru.member_casual, rs.start_station_name
ORDER BY COUNT(rm.stations_id) DESC
LIMIT 3); 

CREATE TEMPORARY TABLE end_member AS
(SELECT
	ru.member_casual,
    rs.end_station_name as station_name,
    'end' AS station_type,
    COUNT(rm.stations_id) AS count
FROM ride_metrics rm
	JOIN
    ride_stations rs ON rs.stations_id = rm.stations_id
    JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
WHERE ru.member_casual = 'member'
GROUP BY ru.member_casual, rs.end_station_name
ORDER BY COUNT(rm.stations_id) DESC
LIMIT 3);


#################################################################
# 9.	What is the most/least used type of bike? Count overall and per user type.
# From the query below: the classic bikes have the highest overall preferece at 58,6%, followed by ebikes at 37,5% and last docked bikes at 3,9%.
# Interesting to point out that only casual riders use the docked bikes.

SELECT 
	*,
    SUM(a.percentage_user_bike) OVER (PARTITION BY a.rideable_type) AS percentage_bike
FROM
	(SELECT
		ru.member_casual,
		ru.rideable_type,
		COUNT(rm.ride_id)/(SELECT COUNT(ride_id) FROM ride_metrics)*100 AS percentage_user_bike
	FROM ride_metrics rm
		JOIN
		ride_usage ru ON ru.usage_id = rm.usage_id
	GROUP BY ru.member_casual, ru.rideable_type
	ORDER BY ru.rideable_type, ru.member_casual DESC) a;
    
    
#################################################################
# 10.	How do users behave over the time of the day? Is there a preferred time for going on a ride? 
# From the query below: Afternoons are the most preferred time of day at 44,1% overall. Followed by morning at 25,0%, then evening at 22,9% and finally night at 8,0%.
# Boths groups have their highest percentages in the afternoon. The only time of day when casuals ride more than members is during the night.

SELECT 
	*,
    SUM(percentage_user_timeofday) OVER (PARTITION BY time_of_day) AS percentage_timeofday
FROM
(SELECT 
	ru.member_casual,
    CASE
		WHEN TIME(rm.started_at) BETWEEN '05:00:00' AND '12:00:00' THEN '1.Morning'
		WHEN TIME(rm.started_at) BETWEEN '12:00:00' AND '18:00:00' THEN '2.Afternoon'
		WHEN TIME(rm.started_at) BETWEEN '18:00:00' AND '22:00:00' THEN '3.Evening'
        ELSE '4.Night'
	END AS time_of_day,
    COUNT(DISTINCT ride_id)/(SELECT COUNT(DISTINCT ride_id) from ride_metrics)*100 AS percentage_user_timeofday
FROM ride_metrics rm
	JOIN
    ride_usage ru ON ru.usage_id = rm.usage_id
GROUP BY ru.member_casual, time_of_day
ORDER BY COUNT(DISTINCT rm.ride_id) DESC) a
ORDER BY time_of_day, member_casual;
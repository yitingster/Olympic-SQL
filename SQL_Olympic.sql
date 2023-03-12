/*Specify database to use*/
USE [Practice1]

/*Join two database*/

ALTER TABLE atheletic_event
ADD Country VARCHAR(50);


UPDATE atheletic_event
SET Country = 
			(SELECT region
			FROM [noc_regions]
			WHERE noc_regions.NOC = atheletic_event.NOC
			);


/* 1. How many Olympic games have been held? */

SELECT COUNT(DISTINCT Games) AS total_olympic_game
FROM [atheletic_event];


/*2. Mention the total no of countries who participated in each olympics game? */

SELECT Games, COUNT(DISTINCT Country) AS Total_countries
FROM [atheletic_event]
GROUP BY Games 
ORDER BY Games; 


 /*3. Which year saw the highest and lowest no of countries participating in olympics? */


WITH year_participant AS
(
	SELECT 
		Games
		, COUNT(DISTINCT Country) Total_countries
		FROM atheletic_event
		GROUP BY Games
),
lowest AS 
(
	SELECT *
	FROM year_participant
	WHERE Total_countries = (SELECT MIN(Total_countries) FROM year_participant)
),
highest AS 
(
	SELECT *
	FROM year_participant
	WHERE Total_countries = (SELECT MAX(Total_countries) FROM year_participant)
)
SELECT (SELECT CONCAT(Games, '-', Total_countries) FROM lowest) AS lowest,
(SELECT CONCAT(Games, '-', Total_countries) from highest) AS highest;


/*4. Which nation has participated in all of the olympic games? */
/* From Question 1, 51 olympic game have been held */

WITH country_games AS
(
	SELECT country
	, COUNT(DISTINCT(Games)) AS total_olympic
	FROM atheletic_event
	GROUP BY country
)
SELECT country, total_olympic
FROM country_games
WHERE total_olympic = (SELECT COUNT(DISTINCT Games) FROM [atheletic_event])
ORDER BY country; 


/*5. Identify the sport which was played in all summer olympics. */

WITH sport_summer AS
(
	SELECT sport
	, COUNT(DISTINCT games) AS total_games
	FROM [atheletic_event]
	WHERE Season = 'Summer'
	GROUP BY sport
)
SELECT Sport, total_games
FROM sport_summer
WHERE total_games = (SELECT MAX(total_games) FROM sport_summer)
ORDER BY Sport;

/*6. Which Sports were just played only once in the olympics? */

WITH sport_game AS 
(
	SELECT Sport, 
	COUNT(DISTINCT Games) AS total_games
	FROM atheletic_event
	GROUP BY Sport
)
SELECT *
FROM sport_game 
WHERE total_games = 1
ORDER BY Sport ASC;


/*7. Fetch the total no of sports played in each olympic games. */

SELECT Games, COUNT(DISTINCT Sport) as no_of_sports
FROM atheletic_event
GROUP BY Games
ORDER BY Games ASC;


/*8. Fetch details of the oldest athletes to win a gold medal. */

WITH age_gold AS
(
	SELECT *
	FROM atheletic_event
	WHERE Medal = 'Gold'
) 
SELECT *
FROM age_gold
WHERE Age = (SELECT MAX(Age) FROM age_gold);

/*9. Find the Ratio of male and female athletes participated in all olympic games. */


SELECT CONCAT( '1:',
(
	SELECT COUNT(Sex)
	FROM atheletic_event
	WHERE Sex = 'M'
) /
(
	SELECT COUNT(Sex)
	FROM atheletic_event
	WHERE Sex = 'F'
)) 
AS F_M_ratio;


/*10. Fetch the top 5 athletes who have won the most gold medals.*/

WITH gold_medals AS
(
	SELECT [Name], COUNT(medal) as total_medals
	FROM atheletic_event 
	WHERE medal = 'Gold'
	GROUP BY [Name]
)	

SELECT *  
FROM gold_medals
WHERE total_medals IN 
(									-- output [23,10,9,9,9]
	SELECT TOP(5) total_medals		
	FROM gold_medals
	ORDER BY total_medals DESC
) 
ORDER BY total_medals DESC, [Name] ASC;

-- There are 4 palyers with 9 gold medals, thus the 6th players would be considered to be in the top 5 too 

/* 11. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won. */

WITH country_medals AS
(
	SELECT country, COUNT(medal) as total_medals
	FROM atheletic_event 
	WHERE medal IN ('Bronze', 'Silver', 'Gold')
	GROUP BY country
)	

SELECT *  
FROM country_medals
WHERE total_medals IN 
(									
	SELECT TOP(5) total_medals		
	FROM country_medals
	ORDER BY total_medals DESC
) 
ORDER BY total_medals DESC;



/*12. List down total gold, silver and broze medals won by each country.*/

SELECT country,
		COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS Gold_medals,
		COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS Silver_medals,
		COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS Bronze_medals
FROM atheletic_event
GROUP BY Country
ORDER BY Gold_medals DESC;

/*13. List down total gold, silver and broze medals won by each country corresponding to each olympic games. */

SELECT Games,
		country,
		COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS Gold_medals,
		COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS Silver_medals,
		COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS Bronze_medals
FROM atheletic_event
GROUP BY Games, Country
ORDER BY Games, Country;

/*14. Identify which country won the most gold, most silver and most bronze medals in each olympic games. */

WITH games_medal_type AS
(
	SELECT Games,
			country,
			COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS Gold_medals,
			COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS Silver_medals,
			COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS Bronze_medals
	FROM atheletic_event
	GROUP BY Games, Country
)
SELECT DISTINCT Games,
				CONCAT(FIRST_VALUE(country) OVER(PARTITION BY Games ORDER BY Gold_medals DESC),
				'-', FIRST_VALUE(Gold_medals) OVER(PARTITION BY Games ORDER BY Gold_medals DESC)) AS Max_Gold,
				CONCAT(FIRST_VALUE(COUNTRY) OVER(PARTITION BY Games ORDER BY Silver_medals DESC),
				'-', FIRST_VALUE(Silver_medals) OVER(PARTITION BY Games ORDER BY Silver_medals DESC)) AS Max_Silver,
				CONCAT(FIRST_VALUE(COUNTRY) OVER(PARTITION BY Games ORDER BY Bronze_medals DESC),
				'-', FIRST_VALUE(Bronze_medals) OVER(PARTITION BY Games ORDER BY Bronze_medals DESC)) AS Max_Bronze
FROM games_medal_type


/*15. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games. */

WITH games_medal_type AS
(
	SELECT Games,
			country,
			COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS Gold_medals,
			COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS Silver_medals,
			COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS Bronze_medals,
			COUNT(CASE WHEN medal != 'NA' THEN 1 END) AS Total_medals
	FROM atheletic_event
	GROUP BY Games, Country
)
SELECT DISTINCT Games,
				CONCAT(FIRST_VALUE(country) OVER(PARTITION BY Games ORDER BY Gold_medals DESC),
				'-', FIRST_VALUE(Gold_medals) OVER(PARTITION BY Games ORDER BY Gold_medals DESC)) AS Max_Gold,
				CONCAT(FIRST_VALUE(COUNTRY) OVER(PARTITION BY Games ORDER BY Silver_medals DESC),
				'-', FIRST_VALUE(Silver_medals) OVER(PARTITION BY Games ORDER BY Silver_medals DESC)) AS Max_Silver,
				CONCAT(FIRST_VALUE(COUNTRY) OVER(PARTITION BY Games ORDER BY Bronze_medals DESC),
				'-', FIRST_VALUE(Bronze_medals) OVER(PARTITION BY Games ORDER BY Bronze_medals DESC)) AS Max_Bronze,
				CONCAT(FIRST_VALUE(COUNTRY) OVER(PARTITION BY Games ORDER BY Total_medals DESC),
				'-', FIRST_VALUE(Total_medals) OVER(PARTITION BY Games ORDER BY Total_medals DESC)) AS Max_medals
FROM games_medal_type;



/*16. Which countries have never won gold medal but have won silver/bronze medals?*/


WITH country_medal_type AS
(
	SELECT country,
			COUNT(CASE WHEN medal = 'Gold' THEN 1 END) AS Gold_medals,
			COUNT(CASE WHEN medal = 'Silver' THEN 1 END) AS Silver_medals,
			COUNT(CASE WHEN medal = 'Bronze' THEN 1 END) AS Bronze_medals
	FROM atheletic_event
	GROUP BY Country
)
SELECT * 
FROM country_medal_type
WHERE Gold_medals = 0
AND (Silver_medals!=0 OR Bronze_medals != 0)
ORDER BY Country;


/*17. In which Sport, Japan has won highest medals. */

SELECT TOP(1) Country, Sport,
		COUNT(CASE WHEN medal != 'NA' THEN 1 END) AS Total_medals
FROM atheletic_event
WHERE Country = 'Japan'
GROUP BY Country, Sport
ORDER BY Total_medals DESC;


/*18. Break down all olympic games where Japan won medal for Gymnastics and how many medals in each olympic games. */

SELECT Country, Sport, Games,
		COUNT(CASE WHEN medal != 'NA' THEN 1 END) AS Total_medals
FROM atheletic_event
WHERE Country = 'Japan'
AND Sport = 'Gymnastics'
GROUP BY Country, Sport, Games
ORDER BY Games;
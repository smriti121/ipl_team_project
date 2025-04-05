use DB1210


select * from dbo.final_silver


-- 1. Team Performance Metrics

CREATE TABLE Team_Performance (
    team_name VARCHAR(255),
    Total_Wins INT,
    Total_Matches INT,
    Win_Percentage DECIMAL(10,2)
);


INSERT INTO Team_Performance (team_name, Total_Wins, Total_Matches, Win_Percentage)
SELECT 
    team_name,
    COUNT(CASE WHEN match_result = 'Win' THEN 1 END) AS Total_Wins,
    COUNT(match_id) AS Total_Matches,
    (COUNT(CASE WHEN match_result = 'Win' THEN 1 END) * 100.0 / COUNT(match_id)) AS Win_Percentage
FROM final_silver
GROUP BY team_name;

select * from Team_Performance



-- 2. Player Contribution

CREATE TABLE Player_Contribution (
    team_name VARCHAR(255),
    player_name VARCHAR(50),
    Total_Runs INT,
    Total_Wickets INT
);


INSERT INTO Player_Contribution (team_name, player_name, Total_Runs, Total_Wickets)
SELECT 
    team_name, 
    player_name,
    SUM(runs_scored) AS Total_Runs,
    SUM(wickets_taken) AS Total_Wickets
FROM final_silver
GROUP BY team_name, player_name;

select * from Player_Contribution

--3. Venue Analysis


CREATE TABLE Venue_Analysis (
    team_id INT,
    team_name VARCHAR(50),
    venue_type VARCHAR(50),
    total_matches INT,
	total_wins INT
);
 

INSERT INTO Venue_Analysis (team_id, team_name, venue_type, total_matches,total_wins)
SELECT 
    team_id,
    team_name,
    venue_type,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN match_result = 'Win' THEN 1 ELSE 0 END) AS total_wins
FROM (
    SELECT *,
        CASE 
            WHEN home_ground = stadium_name THEN 'Home'
            ELSE 'Away'
        END AS venue_type
    FROM dbo.final_silver
) AS sub
GROUP BY team_id, team_name, venue_type;

select* from Venue_Analysis


-- 4. Player Efficiency Metrics


-- average of strike rate, Total wickets, 


CREATE TABLE playerEfficiency1 (
    Total_Runs INT,
    Total_Wickets INT,
    Avg_Strike_Rate INT,
);
 
 INSERT INTO dbo.playerEfficiency1
SELECT  SUM(runs_scored) AS Total_Runs,SUM(wickets_taken) AS Total_Wickets,
    AVG(
        CASE 
            WHEN ball_taken = 0 THEN 0
            ELSE (runs_scored * 100.0 / ball_taken)
        END
    ) AS Avg_Strike_Rate
FROM final_silver;


select * from  dbo.playerEfficiency1

--Gold Table Schema (gold_db.ipl_team_performance_summary) 

CREATE TABLE dbo.ipl_team_performance_summary (
    team_name VARCHAR(100),
    total_matches INT,
    total_wins INT,
    win_percentage FLOAT,
    home_ground VARCHAR(100)
);

INSERT INTO dbo.ipl_team_performance_summary
SELECT 
    team_name,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN match_result = 'Win' THEN 1 ELSE 0 END) AS total_wins,
    ROUND(
        CAST(SUM(CASE WHEN match_result = 'Win' THEN 1 ELSE 0 END) AS FLOAT) 
        / NULLIF(COUNT(*), 0) * 100, 2
    ) AS win_percentage,
    MAX(home_ground) AS home_ground
FROM dbo.final_silver
GROUP BY team_name;

SELECT * FROM dbo.ipl_team_performance_summary;







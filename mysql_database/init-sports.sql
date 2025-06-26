-- teams table
CREATE TABLE teams (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  founded_year INT
);

-- players table
CREATE TABLE players (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  position VARCHAR(50),
  team_id INT,
  FOREIGN KEY (team_id) REFERENCES teams(id)
);

-- sample data
INSERT INTO teams (name, city, founded_year) VALUES
('Toronto Raptors', 'Toronto', 1995),
('Los Angeles Lakers', 'Los Angeles', 1947),
('Golden State Warriors', 'San Francisco', 1946);

INSERT INTO players (name, position, team_id) VALUES
('Scottie Barnes', 'Forward', 1),
('LeBron James', 'Forward', 2),
('Stephen Curry', 'Guard', 3);
// Import the required libraries
const express = require('express');
const mysql = require('mysql');

// Create an Express application
const app = express();
const port = 8080; // The port our application will listen on

// --- Database Connection Configuration ---
// The connection details are read from environment variables
// that Kubernetes will provide to the container.
const db = mysql.createPool({
  host: process.env.DB_HOST,       // e.g., "mysql-sports-service"
  user: process.env.DB_USER,       // e.g., "root"
  password: process.env.DB_PASSWORD, // e.g., "MVSOrtiz2025."
  database: process.env.DB_NAME,     // e.g., "sportsdb"
  connectionLimit: 10              // A standard setting for connection pooling
});

// --- Define the Routes (URL endpoints) ---

// Define the root route ('/')
app.get('/', (req, res) => {
  // SQL query to get players and their teams
  const sql = 'SELECT p.name AS playerName, p.position, t.name AS teamName, t.city FROM players p JOIN teams t ON p.team_id = t.id';

  // Execute the query
  db.query(sql, (err, results) => {
    if (err) {
      // If there's an error, send an error message
      console.error('Error querying database:', err);
      return res.status(500).send('Error connecting to the database. Please check the logs.');
    }
    
    // If successful, render the data as an HTML table
    let html = `
      <h1>Sports Teams and Players</h1>
      <table border="1" cellpadding="5">
        <thead>
          <tr>
            <th>Player Name</th>
            <th>Position</th>
            <th>Team Name</th>
            <th>City</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    results.forEach(row => {
      html += `
        <tr>
          <td>${row.playerName}</td>
          <td>${row.position}</td>
          <td>${row.teamName}</td>
          <td>${row.city}</td>
        </tr>
      `;
    });

    html += `
        </tbody>
      </table>
    `;
    
    // Send the generated HTML as the response
    res.send(html);
  });
});

// --- Start the Server ---
app.listen(port, () => {
  console.log(`Sports web app listening at http://localhost:${port}`);
  console.log('--- Environment Variables ---');
  console.log('DB_HOST:', process.env.DB_HOST);
  console.log('DB_NAME:', process.env.DB_NAME);
  console.log('---------------------------');
});
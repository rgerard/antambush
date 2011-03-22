
// History Table
create table history(id INTEGER PRIMARY KEY, contact VARCHAR(50), attack VARCHAR(50), message VARCHAR(75), time INTEGER);

// Attacks Table
create table attacks(id INTEGER PRIMARY KEY, serverID INTEGER, sender VARCHAR(50), attack VARCHAR(50), message VARCHAR(75), time INTEGER);
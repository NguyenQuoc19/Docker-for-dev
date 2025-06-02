const database = require('../../../../database/init');

const initDatabase = `
    CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
    );

    CREATE TABLE IF NOT EXISTS todos (
    todo_id INTEGER PRIMARY KEY AUTOINCREMENT,
    todo_owner TEXT NOT NULL, 
    title TEXT NOT NULL,
    checked INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    checked_at INTEGER,
    FOREIGN KEY (todo_owner) REFERENCES users (user_id)
    );
`;

database.exec(initDatabase);

module.exports = database;
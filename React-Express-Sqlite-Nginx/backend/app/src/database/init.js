const { DatabaseSync } = require('node:sqlite');

const database = new DatabaseSync('./src/database/data/main.db');

module.exports = database;
db = db.getSiblingDB('db-test');
db.createCollection('test');
db.test4.insertOne({ name: "Check the database was created successfully!" });
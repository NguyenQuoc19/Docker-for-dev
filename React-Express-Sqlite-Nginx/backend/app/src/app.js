require('dotenv').config();

const helmet = require('helmet');
const express = require('express');
const compression = require('compression');

// const logEvents = require('./helpers/log.events');
const indexRouter = require('./routers/index');

// Init App
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware
app.use(helmet());
app.use(compression());


// Only use morgan in development environment
// if (process.env.NODE_ENV === 'development') {
//     const morgan = require('morgan');
// }

// Database connection
// require('./database/init.mongodb');

// Monitor system resources
// const { monitorSystemResources } = require('./helpers/database.helper');
// monitorSystemResources();

// Routes
app.use('/', indexRouter);

// Handling not found errors
app.use((req, res, next) => {
    const error = new Error('Not Found!');
    error.statusCode = 404;
    next(error);
});

// Handling response errors
app.use((err, req, res, next) => {
    const statusCode = err.statusCode || 500;
    // logEvents(`${req.method} : ${err.statusCode} :: ${req.url} : ${err.stack.replace(/\n/g, ' ')}`);
    return res.status(statusCode).json({
        code: statusCode,
        status: false,
        message: err.message || 'Internal Server Error'
    });
});

module.exports = app;
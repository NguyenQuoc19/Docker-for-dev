// require("dotenv").config();

const express = require("express");
const router = express.Router();

// const { signToken, signTokenPermission } = require("../api/v1/modules/sign/sign.controller");

const apiName = process.env.API_NAME || "api";
const apiVersion = process.env.API_VERSION || "v1";

const apiPrefix = `/${apiName}/${apiVersion}`;

// Check the Sign token and Sign token permissions
// router.use(signToken);
// router.use(signTokenPermission(0));

// The main route for the API
router.get(`${apiPrefix}`, (req, res) => {
    return res.status(200).json({
        code: 200,
        status: true,
        message: "Welcome to the API",
        data: {
            name: apiName,
            version: apiVersion,
            description: "This is a sample API",
        }
    });
});

// Access routes
router.use(`${apiPrefix}`, require("../api/v1/modules/user/user.router"));

module.exports = router;
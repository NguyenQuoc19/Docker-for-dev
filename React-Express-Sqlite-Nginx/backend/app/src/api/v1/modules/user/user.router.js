'use strict';

const express = require("express");
const router = express.Router();
const UserController = require("./user.controller");

// Get User
router.get("/user", UserController.getUser);

// Get Users data
router.get("/users", UserController.getUsers);

// Create User
router.post("/user", UserController.createUser);

// Update User
router.put("/user", UserController.updateUser);

// Delete User
router.delete("/user", UserController.deleteUser);

module.exports = router;
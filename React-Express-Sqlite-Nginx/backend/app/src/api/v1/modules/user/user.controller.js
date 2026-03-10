const UserService = require('./user.service');

class UserController {
  getUser = async (req, res, next) => {
    const data = (await UserService.get(req.body)).get();

    if (!data) {
      throw new Error("Could not found user.");
    }

    return res.status(200).json({
      code: 200,
      status: true,
      message: "The User have been retrieved successfully!",
      data: data
    });
  }

  getUsers = async (req, res, next) => {
    const data = (await UserService.getList(req.body)).all();
    if (!data) {
      throw new Error("Could not found user data.");
    }
    return res.status(200).json({
      code: 200,
      status: true,
      message: "User data have been retrieved successfully!",
      data: data
    });
  }

  createUser = async (req, res, next) => {
    req.body.created_at = Date.now();
    const data = (await UserService.create(req.body)).get();
    if (!data) {
      throw new Error("Cannot create new user.");
    }
    return res.status(200).json({
      code: 200,
      status: true,
      message: "User has been created successfully!",
      data: data
    });
  }

  updateUser = async (req, res, next) => {
    const data = (await UserService.update(req.body)).get();
    if (!data) {
      throw new Error("Cannot update new user.");
    }
    return res.status(200).json({
      code: 200,
      status: true,
      message: "User has been updated successfully!",
      data: data
    });
  }

  deleteUser = async (req, res, next) => {
    const data = (await UserService.delete(req.body)).run();
    if (!data) {
      throw new Error("Cannot delete the user.");
    }
    return res.status(200).json({
      code: 200,
      status: true,
      message: "User has been deleted successfully!",
      data: data
    });
  }
}

module.exports = new UserController();
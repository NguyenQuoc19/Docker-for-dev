const UserModel = require('./user.model');

class UserService {
  static get = async ({ username }) => {
    return UserModel.prepare(`SELECT * FROM users WHERE username = '${username}'`);
  }

  static getList = async () => {
    return UserModel.prepare(`SELECT * FROM users LIMIT 10`);
  }

  static create = async ({ username, password, created_at }) => {
    return UserModel.prepare(`
      INSERT INTO users (username, password, created_at)
      VALUES ('${username}', '${password}', '${created_at}')
      RETURNING user_id, username, created_at
    `);
  }

  static update = async ({ user_id, username, password }) => {
    return UserModel.prepare(`
      UPDATE  users
      SET username = '${username}',
          password = '${password}'
      WHERE user_id = '${user_id}'
      RETURNING user_id, username, created_at
    `);
  }

  static delete = async ({ user_id }) => {
    return UserModel.prepare(`
      DELETE from users WHERE user_id = '${user_id}'
    `);
  }
}

module.exports = UserService;
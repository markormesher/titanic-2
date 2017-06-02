rfr = require("rfr")
secrets = rfr("./secrets.json")
Sequelize = require("sequelize")

module.exports = new Sequelize(secrets['MYSQL_CONFIG'])

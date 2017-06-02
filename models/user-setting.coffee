Sequelize = require("sequelize")
rfr = require("rfr")
db = rfr("./helpers/db")
User = rfr("./models/user")

module.exports = db.define('user_setting', {
	userId: {
		type: Sequelize.UUID
		primaryKey: "compositeKey"
		references: {
			model: User
			key: "id"
		}
	}
	key: {
		type: Sequelize.STRING
		primaryKey: "compositeKey"
		allowNull: false
	}
	value: {
		type: Sequelize.STRING
		allowNull: false
	}
})

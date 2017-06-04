Sequelize = require("sequelize")
rfr = require("rfr")
db = rfr("./helpers/db")
User = rfr("./models/user")

module.exports = db.define("api_key", {
	id: {
		type: Sequelize.STRING(32)
		allowNull: false
		primaryKey: true
	}
	owner: {
		type: Sequelize.UUID
		allowNull: false
		references: {
			model: User
			key: "id"
		}
	}
	name: {
		type: Sequelize.STRING
		allowNull: false
	}
	secret: {
		type: Sequelize.STRING(128)
		allowNull: false
	}
})

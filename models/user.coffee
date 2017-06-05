Sequelize = require("sequelize")
rfr = require("rfr")
db = rfr("./helpers/db")

module.exports = db.define("user", {
	id: {
		type: Sequelize.UUID
		allowNull: false
		primaryKey: true
		defaultValue: Sequelize.UUIDV1
	}
	firstName: {
		type: Sequelize.STRING
		allowNull: false
	}
	lastName: {
		type: Sequelize.STRING
		allowNull: false
	}
	email: {
		type: Sequelize.STRING
		allowNull: false
	}
	password: {
		type: Sequelize.STRING(128)
		allowNull: false
	}
})

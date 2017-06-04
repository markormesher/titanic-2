Sequelize = require("sequelize")
rfr = require("rfr")
db = rfr("./helpers/db")
User = rfr("./models/user")

module.exports = db.define("device", {
	id: {
		type: Sequelize.UUID
		allowNull: false
		primaryKey: true
		defaultValue: Sequelize.UUIDV1
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
	ipAddress: {
		type: Sequelize.STRING
		allowNull: false
	}
	type: {
		type: Sequelize.ENUM("workstation", "laptop", "server", "mobile", "other")
		allowNull: false
	}
	active: {
		type: Sequelize.BOOLEAN
		allowNull: false
		default: true
	}
})

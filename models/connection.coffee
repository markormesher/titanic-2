Sequelize = require("sequelize")
rfr = require("rfr")
db = rfr("./helpers/db")
Device = rfr("./models/device")

module.exports = db.define("connection", {
	fromDevice: {
		type: Sequelize.UUID
		allowNull: false
		primaryKey: "compositeKey"
		references: {
			model: Device
			key: "id"
		}
	}
	toDevice: {
		type: Sequelize.UUID
		allowNull: false
		primaryKey: "compositeKey"
		references: {
			model: Device
			key: "id"
		}
	}
})

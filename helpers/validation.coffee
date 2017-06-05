rfr = require("rfr")
validator = require("validator")
constants = rfr("./constants.json")

exp = {

	User: {
		firstName: (data) -> !validator.isEmpty(data)
		lastName: (data) -> !validator.isEmpty(data)
		email: (data) -> validator.isEmail(data)
		password: (data) -> data.length >= 8
	}

	Device: {
		name: (data) -> !validator.isEmpty(data)
		ipAddress: (data) -> validator.isIP(data)
		icon: (data) -> constants["allowedDeviceIcons"].indexOf(data) >= 0
	}

	ApiKey: {
		name: (data) -> !validator.isEmpty(data)
	}

}

module.exports = exp

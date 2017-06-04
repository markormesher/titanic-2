validator = require("validator")

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
		group: (data) -> !validator.isEmpty(data)
		type: (data) -> ["workstation", "laptop", "server", "mobile", "other"].indexOf(data) >= 0
	}

}

module.exports = exp

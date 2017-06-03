validator = require("validator")

exp = {

	User : {
		firstName: (data) -> !validator.isEmpty(data)
		lastName: (data) -> !validator.isEmpty(data)
		email: (data) -> validator.isEmail(data)
		password: (data) -> data.length >= 8
	}

}

module.exports = exp

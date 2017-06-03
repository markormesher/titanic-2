rfr = require("rfr")
hashing = rfr("./helpers/hashing")
constants = rfr("./constants.json")
User = rfr("./models/user")
UserSetting = rfr("./models/user-setting")

manager = {

	getUserForAuth: (emailOrId, password, callback) ->
		User.findOne({
			where: {
				$or: {
					email: emailOrId
					id: emailOrId
				}
				password: hashing.sha256(password)
			}
		}).then((user) ->
			if (user)
				user.dataValues.emailHash = hashing.md5(user.email.trim().toLowerCase())
			callback(null, user)
		).catch((error) ->
			callback(error)
		)


	getUser: (emailOrId, callback) ->
		User.findOne({
			where: {
				$or: {
					email: emailOrId
					id: emailOrId
				}
			}
		}).then((user) ->
			if (user)
				user.dataValues.emailHash = hashing.md5(user.email.trim().toLowerCase())
			callback(null, user)
		).catch((error) ->
			callback(error)
		)


	registerUser: (user, callback) ->
		User.findOne({
			where: {
				email: user.email
			}
		}).then((duplicateUser) ->
			if (duplicateUser)
				callback("duplicate user")
			else
				User.create({
					firstName: user.firstName
					lastName: user.lastName
					email: user.email
					password: hashing.sha256(user.firstPassword)
				}).then(() ->
					callback(null)
				).catch((error) ->
					callback(error)
				)
		)


	saveUser: (user, updatedUser, callback) ->
		# nested function calls: validateEmailChange -> validatePasswordChange -> doUpdate

		doUpdate = (user, updatedUser, newPassword, callback) ->
			updates = {}
			updates["firstName"] = updatedUser["firstName"]
			updates["lastName"] = updatedUser["lastName"]
			updates["email"] = updatedUser["email"]
			if (newPassword)
				updates["password"] = hashing.sha256(newPassword)

			User.update(updates, {
				where: {
					id: user.id
				}
			}).then(() ->
				manager.getUser(user.id, (err, newUser) ->
					if (err) then return callback(err)
					callback(null, newUser)
				)
			).catch((error) ->
				callback(error)
			)

		validatePasswordChange = (user, updatedUser, callback) ->
			# if the current password is set, authenticate it before trying the update
			if (updatedUser["currentPassword"] || updatedUser["firstNewPassword"] || updatedUser["secondNewPassword"])
				if (updatedUser["firstNewPassword"] != updatedUser["secondNewPassword"] || updatedUser["firstNewPassword"].length < 8)
					return callback("invalid password")

				manager.getUserForAuth(user.id, updatedUser["currentPassword"], (err, foundUser) ->
					if (err) then return callback(err)
					if (!foundUser)
						callback("bad password")
					else
						doUpdate(user, updatedUser, updatedUser["firstNewPassword"], callback)
				)
			else
				doUpdate(user, updatedUser, null, callback)

		validateEmailChange = (user, updatedUser, callback) ->
			User.findOne({
				where: {
					email: updatedUser["email"],
					$not: {
						id: user.id
					}
				}
			}).then((conflict) ->
				if (conflict)
					callback("duplicate email")
				else
					validatePasswordChange(user, updatedUser, callback)
			).catch((error) ->
				callback(error)
			)

		# start the call chain
		validateEmailChange(user, updatedUser, callback)


	getUserSettings: (user, callback) ->
		settings = constants["defaultSettings"]
		UserSetting.findAll({
			where: {
				userId: user.id
			}
		}).then((customSettings) ->
			for c in customSettings
				settings[c["key"]] = c["value"]
			settings["__version"] = constants["settingsVersion"]
			callback(null, settings)
		).catch((error) ->
			callback(error)
		)


	setUserSettings: (user, settings, callback) ->
		inserts = []
		for k, v of settings
			inserts.push({
				userId: user.id,
				key: k,
				value: v
			})

		UserSetting.bulkCreate(inserts, { updateOnDuplicate: true })

		callback(null)
}

module.exports = manager

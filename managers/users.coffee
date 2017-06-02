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

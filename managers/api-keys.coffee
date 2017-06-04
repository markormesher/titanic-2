uuid = require("uuid")
rfr = require("rfr")
validation = rfr("./helpers/validation")
hashing = rfr("./helpers/hashing")
ApiKey = rfr("./models/api-key")

manager = {

	getKeys: (owner, callback) ->
		ApiKey.findAll({
			where: {
				owner: owner.id
			}
			order: [
				["name", "ASC"]
			]
		}).then((results) ->
			callback(null, results)
		).catch((error) ->
			callback(error)
		)


	getKey: (owner, id, callback) ->
		ApiKey.findOne({ where: {
			id: id
			owner: owner.id
		} }).then((device) ->
			callback(null, device)
		).catch((error) ->
			callback(error)
		)


	generateKey: (owner, name, callback) ->

		validate = () ->
			errors = []
			if (!validation.ApiKey.name(name)) then errors.push("invalid name")

			if (errors.length)
				callback(errors)
			else
				checkUniqueName()

		checkUniqueName = () ->
			ApiKey.findOne({ where: {
				owner: owner.id
				name: name
			} }).then((conflict) ->
				if (conflict)
					callback(["duplicate name"])
				else
					doGenerate()
			).catch((error) ->
				callback(error)
			)

		doGenerate = () ->
			# split/join is faster than regex in v8
			keyId = uuid.v4()
			keyCleanId = keyId.split("-").join("")
			keySecret = uuid.v4().split("-").join("")
			keyHash = hashing.sha512(keySecret)

			ApiKey.create({
				id: keyId
				owner: owner.id
				name: name
				secret: keyHash
			}).then(() ->
				callback(null, keyCleanId + keySecret)
			).catch((error) ->
				callback(error)
			)

		validate()


	revokeKey: (owner, id, callback) ->

		checkOwnership = () ->
			ApiKey.findOne({ where: {
				id: id
				owner: owner.id
			} }).then((result) ->
				if (result)
					doDelete()
				else
					callback(new Error("No such key"))
			).catch((error) ->
				callback(error)
			)

		doDelete = () ->
			ApiKey.destroy({ where: {
				id: id
			} }).then(() ->
				callback(null)
			).catch((error) ->
				callback(error)
			)

		checkOwnership()


	validateKey: (key, callback) ->
		console.log(key)

		# basic format validation
		if (typeof key != typeof "") then return callback("invalid key")
		key = key.trim()
		if (key.length != 64) then return callback("invalid key")

		# break up id and secret
		keyId = key[0..7] + "-" + key[8..11] + "-" + key[12..15] + "-" + key[16..19] + "-" + key[20..31]
		keySecret = key[32..63]

		ApiKey.findOne({ where: {
			id: keyId
			secret: hashing.sha512(keySecret)
		} }).then((result) ->
			if (!result)
				callback("key does not exist")
			else
				callback(null, result["owner"])
		).catch((error) ->
			callback(error)
		)
}

module.exports = manager

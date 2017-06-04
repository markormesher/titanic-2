uuid = require("uuid")
rfr = require("rfr")
validation = rfr("./helpers/validation")
hashing = rfr("./helpers/hashing")
ApiKey = rfr("./models/api-key")

manager = {

	getKeys: (owner, callback) ->
		ApiKey.findAll({ where: {
			owner: owner.id
		}}).then((results) ->
			callback(null, results)
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
			keyId = uuid.v4().split("-").join("")
			keySecret = uuid.v4().split("-").join("")
			keyHash = hashing.sha512(keySecret)

			ApiKey.create({
				id: keyId
				owner: owner.id
				name: name
				secret: keyHash
			}).then(() ->
				callback(null, keyId+keySecret)
			).catch((error) ->
				callback(error)
			)

		validate()
}

module.exports = manager

rfr = require("rfr")
validation = rfr("./helpers/validation")
Device = rfr("./models/device")

manager = {

	getDevices: (owner, callback) ->
		Device.findAll({
			where: {
				owner: owner.id
			}
			order: [
				["name", "ASC"]
			]
		}).then((devices) ->
			if (!(devices instanceof Array))
				devices = [devices]
			callback(null, devices)
		).catch((error) ->
			callback(error)
		)


	getDevice: (owner, id, callback) ->
		Device.findOne({ where: {
			id: id
			owner: owner.id
		} }).then((device) ->
			callback(null, device)
		).catch((error) ->
			callback(error)
		)


	saveDevice: (owner, id, device, callback) ->
		validate = () ->
			errors = []
			if (!validation.Device.name(device["name"])) then errors.push("invalid name")
			if (!validation.Device.ipAddress(device["ipAddress"])) then errors.push("invalid ip address")
			if (!validation.Device.group(device["group"])) then errors.push("invalid group")
			if (!validation.Device.type(device["type"])) then errors.push("invalid type")

			if (errors.length)
				callback(errors)
			else
				checkOwnership()

		checkOwnership = () ->
			if (!id || id == "0")
				checkUniqueName()
			else
				Device.findOne({ where: {
					id: id
					owner: owner.id
				} }).then((result) ->
					if (result)
						checkUniqueName()
					else
						callback(new Error("No such device"))
				).catch((error) ->
					callback(error)
				)

		checkUniqueName = () ->
			if (!id || id == "0")
				doSave()
			else
				Device.findOne({ where: {
					owner: owner.id
					name: device["name"]
					$not: { id: id }
				} }).then((conflict) ->
					if (conflict)
						callback(["duplicate name"])
					else
						doSave()
				).catch((error) ->
					callback(error)
				)

		doSave = () ->
			if (id && id != "0")
				device["id"] = id

			device["owner"] = owner.id

			Device.upsert(device).then(() ->
				callback(null)
			).catch((error) ->
				callback(error)
			)

		validate()
}

module.exports = manager

rfr = require("rfr")
Device = rfr("./models/device")
Connection = rfr("./models/connection")

manager = {

	getOutgoingConnectionsForDevice: (owner, deviceName, callback) ->

		deviceId = null

		checkOwnership = () ->
			Device.findOne({ where: {
				owner: owner.id
				name: deviceName
				active: true
			} }).then((device) ->
				if (device)
					deviceId = device["id"]
					queryConnections()
				else
					callback(new Error("No such device"))
			).catch((error) ->
				callback(error)
			)

		queryConnections = () ->
			callback(null, {})

		checkOwnership()

}

module.exports = manager

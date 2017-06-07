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
			).catch(callback)

		queryConnections = () ->
			Connection.findAll({ where: {
				fromDevice: deviceId
			} }).then((connections) ->
				targetDeviceIds = []
				for c in connections
					targetDeviceIds.push(c["toDevice"])

				Device.findAll({ where: {
					id: targetDeviceIds
				} }).then((devices) ->
					callback(null, devices)
				).catch(callback)
			).catch(callback)

		checkOwnership()

}

module.exports = manager

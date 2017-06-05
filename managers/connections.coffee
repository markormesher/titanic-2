Array::unique = ->
	output = {}
	output[@[key]] = @[key] for key in [0...@length]
	value for key, value of output

rfr = require("rfr")
validation = rfr("./helpers/validation")
Device = rfr("./models/device")
Connection = rfr("./models/connection")

manager = {

	getConnections: (owner, deviceId, callback) ->

		checkOwnership = () ->
			Device.findOne({ where: {
				id: deviceId
				owner: owner.id
				active: true
			} }).then((result) ->
				if (result)
					queryConnections()
				else
					callback(new Error("No such device"))
			).catch((error) ->
				callback(error)
			)

		queryConnections = () ->
			Connection.findAll({ where: {
				$or: {
					fromDevice: deviceId
					toDevice: deviceId
				}
			} }).then((results) ->
				output = {
					outgoing: []
					incoming: []
				}

				for r in results
					if (r["fromDevice"] == deviceId)
						output.outgoing.push(r["toDevice"])
					else
						output.incoming.push(r["fromDevice"])

				callback(null, output)
			).catch((error) ->
				callback(error)
			)

		checkOwnership()


	updateConnections: (owner, deviceId, connections, callback) ->

		checkMainDeviceOwnership = () ->
			Device.findOne({ where: {
				id: deviceId
				owner: owner.id
				active: true
			} }).then((result) ->
				if (result)
					checkOtherDeviceOwnership()
				else
					callback(new Error("No such device"))
			).catch((error) ->
				callback(error)
			)

		checkOtherDeviceOwnership = () ->
			otherIds = connections["outgoing"].concat(connections["incoming"]).unique()

			Device.findAll({ where: {
				id: {
					$in: otherIds
				}
				owner: owner.id
			} }).then((result) ->
				if (result.length == otherIds.length)
					clearOldConnections()
				else
					callback(new Error("No such device"))
			).catch((error) ->
				callback(error)
			)

		clearOldConnections = () ->
			Connection.destroy({ where: {
				$or: {
					fromDevice: deviceId
					toDevice: deviceId
				}
			} }).then(() ->
				createNewConnections()
			).catch((error) ->
				callback(error)
			)

		createNewConnections = () ->
			inserts = []
			for id in connections["outgoing"]
				inserts.push({
					fromDevice: deviceId
					toDevice: id
				})
			for id in connections["incoming"]
				inserts.push({
					fromDevice: id
					toDevice: deviceId
				})

			Connection.bulkCreate(inserts).then(() ->
				callback(null)
			).catch((error) ->
				callback(error)
			)

		checkMainDeviceOwnership()
}

module.exports = manager

async = require("async")
rfr = require("rfr")
auth = rfr("./helpers/auth")
express = require("express")
DeviceManager = rfr("./managers/devices")
ConnectionManager = rfr("./managers/connections")
constants = rfr("./constants.json")

router = express.Router()

router.get("/", auth.checkAndRefuse, (req, res, next) ->
	DeviceManager.getDevices(res.locals.user, (err, devices) ->
		if (err) then return next(err)
		res.render("devices/index", {
			_: {
				title: "Manage Devices"
				activePage: "devices"
			}
			devices: devices
		})
	)
)

router.get("/edit/:deviceId", auth.checkAndRefuse, (req, res, next) ->
	deviceId = req.params["deviceId"]
	createMode = !deviceId || deviceId == "0"

	render = (device) ->
		res.render("devices/edit", {
			_: {
				title: if (createMode) then "Create Device" else "Edit Device"
				activePage: "devices"
			}
			createMode: createMode
			device: device
			deviceId: deviceId
			icons: constants["allowedDeviceIcons"]
		})

	if (createMode)
		render({})
	else
		DeviceManager.getDevice(res.locals.user, deviceId, (err, device) ->
			if (err) then return next(err)
			if (device)
				render(device)
			else
				req.flash("error", "Device not found.")
				res.redirect("/devices")
		)
)

router.post("/edit/:deviceId", auth.checkAndRefuse, (req, res, next) ->
	deviceId = req.params["deviceId"]
	createMode = !deviceId || deviceId == "0"
	device = req.body

	DeviceManager.saveDevice(res.locals.user, deviceId, device, (errors) ->
		if (!errors || errors.length == 0)
			req.flash("success", "Device saved.")
			res.redirect("/devices")

		else
			if (errors instanceof Array)
				for err in errors
					switch (err)
						when "invalid name" then req.flash("error", "You did not enter a valid device name.")
						when "invalid ip address" then req.flash("error", "You did not enter a valid IP address.")
						when "invalid icon" then req.flash("error", "You did not select a valid icon.")
						when "duplicate name" then req.flash("error", "The name you entered is already in use.")
						else
							return next(err)

				res.render("devices/edit", {
					_: {
						title: if (createMode) then "Create Device" else "Edit Device"
						activePage: "devices"
					}
					createMode: createMode
					device: device
					deviceId: deviceId
					icons: constants["allowedDeviceIcons"]
				})

			else
				return next(errors)
	)
)

router.get("/delete/:deviceId", auth.checkAndRefuse, (req, res, next) ->
	deviceId = req.params["deviceId"]

	DeviceManager.getDevice(res.locals.user, deviceId, (error, device) ->
		if (error)
			next(error)
		else
			res.render("devices/delete", {
				_: {
					title: "Delete Device"
					activePage: "devices"
				}
				device: device
				deviceId: deviceId
			})
	)
)

router.get("/confirm-delete/:deviceId", auth.checkAndRefuse, (req, res, next) ->
	deviceId = req.params["deviceId"]

	DeviceManager.deleteDevice(res.locals.user, deviceId, (error) ->
		if (error)
			next(error)
		else
			req.flash("success", "Device deleted.")
			res.redirect("/devices")
	)
)

router.get("/connections/:deviceId", auth.checkAndRefuse, (req, res, next) ->
	deviceId = req.params["deviceId"]

	async.parallel({
		device: (cb) -> DeviceManager.getDevice(res.locals.user, deviceId, cb)
		deviceList: (cb) -> DeviceManager.getDevices(res.locals.user, cb)
		connections: (cb) -> ConnectionManager.getConnections(res.locals.user, deviceId, cb)
	}, (error, results) ->
		if (error)
			next(error)
		else
			res.render("devices/connections", {
				_: {
					title: "Manage Connections"
					activePage: "devices"
				}
				device: results.device
				deviceId: deviceId
				deviceList: results.deviceList.filter((d) -> d["id"] != deviceId)
				connections: results.connections
			})
	)
)

router.post("/connections/:deviceId", auth.checkAndRefuse, (req, res, next) ->
	deviceId = req.params["deviceId"]
	connections = req.body

	if (!connections["outgoing"])
		connections["outgoing"] = []
	if (!connections["incoming"])
		connections["incoming"] = []

	if (!Array.isArray(connections["outgoing"]))
		connections["outgoing"] = [connections["outgoing"]]
	if (!Array.isArray(connections["incoming"]))
		connections["incoming"] = [connections["incoming"]]

	ConnectionManager.updateConnections(res.locals.user, deviceId, connections, (error) ->
		if (error)
			next(error)
		else
			req.flash("success", "Connections saved.")
			res.redirect("/devices")
	)
)

module.exports = router

rfr = require("rfr")
auth = rfr("./helpers/auth")
express = require("express")
DeviceManager = rfr("./managers/devices")

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
						when "invalid type" then req.flash("error", "You did not select a valid type.")
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
				})

			else
				return next(errors)
	)
)

module.exports = router

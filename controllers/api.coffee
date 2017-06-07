rfr = require("rfr")
auth = rfr("./helpers/auth")
express = require("express")
ApiManager = rfr("./managers/api")

router = express.Router()

router.get("/user", auth.checkAndRefuseForApi, (req, res) ->
	res.json(res.locals.user)
)

router.post("/connections", auth.checkAndRefuseForApi, (req, res) ->
	deviceName = req.body["identity"]
	ApiManager.getOutgoingConnectionsForDevice(res.locals.user, deviceName, (error, data) ->
		if (error)
			res.status(400).send(error.message)
		else
			res.json(data)
	)
)

module.exports = router

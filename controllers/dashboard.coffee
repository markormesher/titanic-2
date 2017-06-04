rfr = require("rfr")
auth = rfr("./helpers/auth")
express = require("express")

router = express.Router()

router.get("/", auth.checkAndRefuse, (req, res) ->
	res.render("dashboard/index", {
		_: {
			title: "Dashboard"
			activePage: "dashboard"
		}
	})
)

module.exports = router

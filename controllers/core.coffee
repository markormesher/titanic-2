express = require("express")
router = express.Router()

router.get("/", (req, res) ->
	res.render("core/index", {
		_: {
			title: "About Titanic"
			activePage: "about"
		}
	})
)

module.exports = router

rfr = require("rfr")
auth = rfr("./helpers/auth")
express = require("express")
ApiKeyManager = rfr("./managers/api-keys")

router = express.Router()

router.get("/", auth.checkAndRefuse, (req, res, next) ->
	ApiKeyManager.getKeys(res.locals.user, (err, keys) ->
		if (err) then return next(err)
		res.render("api-keys/index", {
			_: {
				title: "API Keys"
				activePage: "api-keys"
			}
			keys: keys
		})
	)
)

router.get("/create", auth.checkAndRefuse, (req, res) ->
	res.render("api-keys/create", {
		_: {
			title: "Create API Key"
			activePage: "api-keys"
		}
	})
)

router.post("/create", auth.checkAndRefuse, (req, res, next) ->
	name = req.body["name"]

	ApiKeyManager.generateKey(res.locals.user, name, (errors, key) ->
		if (!errors || errors.length == 0)
			res.render("api-keys/output", {
				_: {
					title: "Create API Key"
					activePage: "api-keys"
				}
				key: key
			})

		else
			if (errors instanceof Array)
				for err in errors
					switch (err)
						when "invalid name" then req.flash("error", "You did not enter a valid key name.")
						when "duplicate name" then req.flash("error", "The name you entered is already in use.")
						else
							return next(err)

				res.render("api-keys/create", {
					_: {
						title: "Create API Key"
						activePage: "api-keys"
					}
					name: name
				})

			else
				return next(errors)
	)
)

module.exports = router
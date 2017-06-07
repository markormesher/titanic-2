crypto = require("crypto")
rfr = require("rfr")
constants = rfr("./constants.json")
UserManager = rfr("./managers/users")
ApiKeyManager = rfr("./managers/api-keys")

exports = {

	userHasSetting: (user) -> user["settings"] && user["settings"]["__version"] == constants["settingsVersion"]

	checkOnly: (req, res, next) ->
		user = req.user
		res.locals.user = user || null
		if (user && !exports.userHasSetting(user))
			UserManager.getUserSettings(user, (err, settings) ->
				if (err) then return next(err)
				user["settings"] = settings
				req.login(user, (err) -> next(err))
			)
		else
			next()


	checkAndRefuse: (req, res, next) ->
		if (req.user)
			exports.checkOnly(req, res, next)
		else
			req.flash("error", "You need to log in first.")
			res.redirect("/auth/login")


	checkAndRefuseForApi: (req, res, next) ->
		apiKey = req.header("Authorization")
		if (!apiKey) then return res.status(400).send("No API key provided")

		ApiKeyManager.validateKey(apiKey, (error, userId) ->
			if (error)
				res.status(401).send("API key invalid")
			else
				UserManager.getUser(userId, (error, user) ->
					if (error)
						res.status(500).send("Could not retrieve user")
					else
						res.locals.user = user
						next()
				)
		)
}

module.exports = exports

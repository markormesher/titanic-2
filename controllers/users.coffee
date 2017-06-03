rfr = require("rfr")
auth = rfr("./helpers/auth")
express = require("express")
UserManager = rfr("./managers/users")

router = express.Router()

router.get("/profile", auth.checkAndRefuse, (req, res) ->
	res.render("users/profile", {
		_: {
			activePage: "profile"
		}
	})
)

router.post("/profile", auth.checkAndRefuse, (req, res, next) ->
	updates = req.body

	UserManager.saveUser(res.locals.user, updates, (err, updatedUser) ->
		if (err)
			if (err == "duplicate email")
				req.flash("error", "That email address is already in use.")
				res.redirect("/users/profile")
			else if (err == "invalid password")
				req.flash("error", "Your new password is not valid.")
				res.redirect("/users/profile")
			else if (err == "bad password")
				req.flash("error", "You current password was not correct.")
				res.redirect("/users/profile")
			else
				return next(err)
		else
			req.flash("success", "Your details have been updated.")
			req.login(updatedUser, (err) ->
				if (err) then return next(err)
				res.redirect("/users/profile")
			)
	)
)

module.exports = router

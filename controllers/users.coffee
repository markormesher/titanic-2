rfr = require("rfr")
auth = rfr("./helpers/auth")
express = require("express")
UserManager = rfr("./managers/users")

router = express.Router()

router.get("/profile", auth.checkAndRefuse, (req, res) ->
	res.render("users/profile", {
		_: {
			title: "Edit Your Profile"
			activePage: "profile"
		}
	})
)

router.post("/profile", auth.checkAndRefuse, (req, res, next) ->
	updates = req.body

	UserManager.saveUser(res.locals.user, updates, (errors, updatedUser) ->
		if (!errors || errors.length == 0)
			req.flash("success", "Your details have been updated.")
			req.login(updatedUser, (err) ->
				if (err) then return next(err)
				res.redirect("/users/profile")
			)

		else
			if (errors instanceof Array)
				for err in errors
					switch (err)
						when "invalid first name" then req.flash("error", "You did not enter a valid first name.")
						when "invalid last name" then req.flash("error", "You did not enter a valid last name.")
						when "invalid email" then req.flash("error", "You did not enter a valid email address.")
						when "duplicate email" then req.flash("error", "The email address you entered is already in use.")
						when "invalid password" then req.flash("error", "Your new password is not valid.")
						when "mismatched passwords" then req.flash("error", "Your new passwords did not match.")
						when "bad password" then req.flash("error", "You current password was not correct.")
						else
							return next(err)

				res.redirect("/users/profile")

			else
				return next(err)
	)
)

module.exports = router

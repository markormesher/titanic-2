express = require("express")
passport = require("passport")
rfr = require("rfr")
UserManager = rfr("./managers/users")
router = express.Router()

router.get("/", (req, res) -> res.redirect("/auth/login"))

router.get("/login", (req, res) ->
	res.render("auth/login", {
		_: {
			title: "Login"
			activePage: "auth"
		}
	})
)

router.post("/login", passport.authenticate("local", {
	successRedirect: "/dashboard"
	failureRedirect: "/auth/login"
}))

router.get("/register", (req, res) ->
	res.render("auth/register", {
		_: {
			title: "Register"
			activePage: "register"
		}
	})
)

router.post("/register", (req, res) ->
	user = req.body

	UserManager.registerUser(user, (errors) ->
		if (!errors || errors.length == 0)
			req.flash("success", "Your account has been created!")
			req.flash("data-username", user.email)
			res.redirect("/auth/login")

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
						else
							return next(err)

				res.render("auth/register", {
					_: {
						title: "Register"
						activePage: "register"
					}
					user: user
				})

			else
				return next(err)
	)
)

router.get("/logout", (req, res) ->
	req.logout()
	req.flash("info", "You have been logged out.")
	res.redirect("/auth/login")
)

module.exports = router

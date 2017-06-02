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
	UserManager.registerUser(user, (err) ->
		if (err == "duplicate user")
			req.flash("error", "A user with that email address already exists!")
			res.render("auth/register", {
				_: {
					title: "Register"
					activePage: "register"
				}
				user: user
			})
		else if (err != null)
			next(err)
		else
			req.flash("success", "Your account has been created!")
			req.flash("data-username", user.email)
			res.redirect("/auth/login")
	)
)

router.get("/logout", (req, res) ->
	req.logout()
	req.flash("info", "You have been logged out.")
	res.redirect("/auth/login")
)

module.exports = router

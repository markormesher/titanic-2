path = require("path")
express = require("express")
bodyParser = require("body-parser")
coffeeMiddleware = require("coffee-middleware")
sassMiddleware = require("node-sass-middleware")
cookieParser = require("cookie-parser")
session = require("cookie-session")
flash = require("express-flash")
passport = require("passport")

rfr = require("rfr")
auth = rfr("./helpers/auth")
secrets = rfr("./secrets.json")
packageData = rfr("./package.json")
constants = rfr("./constants.json")

app = express()

# sync DB models (note: order must reflect FK dependencies)
models = ["user", "user-setting", "api-key", "device", "connection"]
initModel = (i) ->
	if (i >= models.length) then return
	rfr("./models/#{models[i]}").sync().then(() -> initModel(i + 1)).catch((err) -> throw err)
initModel(0)

# form body content
app.use(bodyParser.urlencoded({ extended: false }));

# coffee script and sass conversion
app.use(coffeeMiddleware({
	src: __dirname + "/assets"
	compress: true
	encodeSrc: false
}))
app.use(sassMiddleware({
	src: __dirname + "/assets/"
	dest: __dirname + "/public"
	outputStyle: "compressed"
}))

# cookies and sessions
app.use(cookieParser(secrets["COOKIE_KEY"]))
app.use(session({
	name: "session"
	maxAge: 1000 * 60 * 60 * 24 * 14 # two weeks
	secret: secrets["SESSION_KEY"]
}))

# update the session every minute to re-set expiration timer
app.use((req, res, next) ->
	req.session.nowInMinutes = Date.now() / (60 * 1000)
	next()
)

# flash, with customisation for data
app.use(flash())
app.use((req, res, next) ->
	if (req.session.flash)
		req.session.flash.data = {}
		for key, value of req.session.flash
			if (key.substring(0, 5) == "data-")
				req.session.flash.data[key.substring(5)] = value[0]
	next()
)

# auth
rfr("./helpers/passport-config")(passport)
app.use(passport.initialize())
app.use(passport.session())
app.use(auth.checkOnly)

# helpers
app.locals.constants = constants

# routes
app.use("/", rfr("./controllers/core"))
app.use("/api", rfr("./controllers/api"))
app.use("/api-keys", rfr("./controllers/api-keys"))
app.use("/auth", rfr("./controllers/auth"))
app.use("/dashboard", rfr("./controllers/dashboard"))
app.use("/devices", rfr("./controllers/devices"))
app.use("/users", rfr("./controllers/users"))

# favicon be-gone!
app.use("/favicon.ico", (req, res) -> res.end())

# views
app.set("views", path.join(__dirname, "views"))
app.set("view engine", "pug")
app.use(express.static(path.join(__dirname, "public")))

# catch-all route for 404 errors
app.use((req, res, next) ->
	err = new Error("Not Found: " + req.url)
	err.status = 404
	next(err)
)

# error handler
app.use((error, req, res, next) ->
	visibleError = {}
	if app.get("env") == "development"
		Object.getOwnPropertyNames(error).forEach((key) -> visibleError[key] = error[key])
		if (visibleError["stack"])
			visibleError["stack"] = visibleError["stack"].split("\n").map((line) -> line.trim())
	else
		visibleError = { incidentId: require("uuid").v4() }

	res.status(error.status || 500)
	res.render("core/error", {
		_: {
			title: "Error"
		}
		status: error.status || 500
		error: visibleError
	})
)

# go!
app.listen(constants["port"])
console.log("#{packageData["name"]} is listening on port #{constants["port"]}")

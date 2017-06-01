rfr = require("rfr")
mysql = rfr("./helpers/mysql")
hashing = rfr("./helpers/hashing")
constants = rfr("./constants.json")

manager = {

	getUserForAuth: (emailOrId, password, callback) ->
		query = "SELECT * FROM user WHERE (email = ? OR id = ?) AND password = ? LIMIT 1;"
		data = [emailOrId, emailOrId, hashing.sha256(password)]
		mysql.query(query, data, (err, results) ->
			if (err) then return callback(err)
			if (results && results.length == 1) then return callback(null, results[0])
			callback(null, null)
		)


	getUser: (emailOrId, callback) ->
		query = "SELECT * FROM user WHERE email = ? OR id = ? LIMIT 1;"
		data = [emailOrId, emailOrId]
		mysql.query(query, data, (err, results) ->
			if (err) then return callback(err)
			if (results && results.length == 1) then return callback(null, results[0])
			callback(null, null)
		)


	getUserSettings: (userId, callback) ->
		settings = constants["defaultSettings"]
		query = "SELECT * FROM setting WHERE user_id = ?;"
		data = [userId]
		mysql.query(query, data, (err, results) ->
			if (err) then return callback(err)
			for r in results
				settings[r["setting_key"]] = r["setting_value"]
			settings["__version"] = constants["settingsVersion"]
			callback(null, settings)
		)


	setUserSettings: (userId, settings, callback) ->
		inserts = []
		for k, v of settings
			inserts.push([userId, k, v])

		query = "REPLACE INTO setting VALUES ?;"
		data = [inserts]
		mysql.query(query, data, callback)
}

module.exports = manager

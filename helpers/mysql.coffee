mysql = require('mysql')
rfr = require('rfr')
secrets = rfr('./secrets.json')

poolConfig = secrets['MYSQL_CONFIG']
poolConfig['connectionLimit'] = 10
poolConfig['multipleStatements'] = true
pool = mysql.createPool(poolConfig)

exp = {

	getConnection: (onReady) ->
		pool.getConnection((err, conn) ->
			if (err) then throw err
			onReady(conn)
		)

	query: (query, data, callback) ->
		exp.getConnection((conn) -> conn.query(query, data, (err, results) ->
			conn.release()
			callback(err, results)
		))

}

module.exports = exp

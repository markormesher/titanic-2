crypto = require("crypto")
exports = {
	# shortcut for password hashing
	hashPassword: (data) -> exports.sha512(data)

	sha512: (data) -> crypto.createHash("sha512").update(data).digest("hex")
	md5: (data) -> crypto.createHash("md5").update(data).digest("hex")
}
module.exports = exports

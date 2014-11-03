mongoose = require('mongoose')
bcrypt   = require('bcrypt-nodejs')

schema =
  local:
    email: String
    password: String
  facebook:
    id: String
    token: String
    email: String
    name: String
  twitter:
    id: String
    token: String
    displayName: String
    username: String
  google:
    id: String
    token: String
    email: String
    name: String

userSchema = mongoose.Schema schema

userSchema.methods.generateHash = (password) ->
  bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)

userSchema.methods.validPassword = (password) ->
  bcrypt.compareSync(password, @local.password)

module.exports = mongoose.model('User', userSchema)
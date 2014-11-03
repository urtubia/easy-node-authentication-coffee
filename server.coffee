express = require('express')
passport = require('passport')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
morgan = require('morgan')
mongoose = require('mongoose')
app = express()
configDb = require('./config/database')
flash = require('connect-flash')

mongoose.connect configDb.url
require('./config/passport')(passport)

app.use morgan('dev')
app.use cookieParser()
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: true })
app.set 'view engine', 'ejs'
app.use session({secret: 'dui3jd'})
app.use passport.initialize()
app.use passport.session()
app.use flash()

require('./app/routes')(app, passport)

server = app.listen 3000, () ->
  host = server.address().address
  port = server.address().port

  console.log "Listening on #{host} #{port}"

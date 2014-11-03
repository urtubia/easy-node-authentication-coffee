LocalStrategy = require('passport-local').Strategy
FacebookStrategy = require('passport-facebook').Strategy
TwitterStrategy = require('passport-twitter').Strategy
GoogleStrategy = require('passport-google-auth').Strategy

User = require('../app/models/user')
configAuth= require('./auth')

module.exports = (passport) ->
  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done(err, user)

  passport.use 'local-signup', new LocalStrategy {usernameField: 'email', passwordField: 'password', passReqToCallback: true} , (req, email, password, done) ->
    process.nextTick () ->
      User.findOne {'local.email':email }, (err, user) ->
        if err
          return done(err)
        if user
          return done(null, false, req.flash('signupMessage', 'Email already Taken'))
        else
          newUser = new User()
          newUser.local.email = email
          newUser.local.password = newUser.generateHash password
          newUser.save (err) ->
            if err
              throw err
            done(null, newUser)

  passport.use 'local-login', new LocalStrategy {usernameField: 'email', passwordField: 'password', passReqToCallback: true}, (req, email, password, done) ->
    User.findOne {'local.email':email}, (err, user) ->
      if err
        return done(err)
      if not user
        return done(null, false, req.flash 'loginMessage', "No user found")
      if not user.validPassword(password)
        return done(null, false, req.flash 'loginMessage', "Wrong Password")
      return done null, user

  passport.use new FacebookStrategy {clientID: configAuth.facebookAuth.clientId, clientSecret: configAuth.facebookAuth.clientSecret, callbackURL: configAuth.facebookAuth.callbackURL}, (token, refreshToken, profile, done) ->
    process.nextTick () ->
      User.findOne { 'facebook.id': profile.id }, (err, user) ->
        if err
          return done(err)
        if user
          return done(null, user)
        else
          newUser = new User()
          newUser.facebook.id = profile.id
          newUser.facebook.token = token
          newUser.facebook.name = profile.name.givenName + ' ' + profile.name.familyName
          newUser.facebook.email = profile.emails[0].value
          newUser.save (err) ->
            if err
              throw err
            return done(null, newUser)

  passport.use new TwitterStrategy {consumerKey: configAuth.twitterAuth.consumerKey, consumerSecret: configAuth.twitterAuth.consumerSecret, callbackURL: configAuth.twitterAuth.callbackURL}, (token, tokenSecret, profile, done) ->
    process.nextTick () ->
      User.findOne { 'twitter.id': profile.id }, (err, user) ->
        if err
          return done(err)
        if user
          return done(null, user)
        else
          newUser = new User()
          newUser.twitter.id = profile.id
          newUser.twitter.token = token
          newUser.twitter.username = profile.username
          newUser.twitter.displayName = profile.displayName
          newUser.save (err) ->
            if err
              throw err
            return done(null, newUser)

  # Note: http://stackoverflow.com/questions/22870082/getting-error-403-access-not-configured-please-use-google-developers-console-t
  passport.use new GoogleStrategy {clientId: configAuth.googleAuth.clientId, clientSecret: configAuth.googleAuth.clientSecret, callbackURL: configAuth.googleAuth.callbackURL}, (token, refreshToken, profile, done) ->
    process.nextTick () ->
      User.findOne { 'google.id': profile.id }, (err, user) ->
        if err
          return done(err)
        if user
          return done(null, user)
        else
          newUser = new User()
          newUser.google.id = profile.id
          newUser.google.token = token
          newUser.google.name = profile.displayName
          newUser.google.email = profile.emails[0].value
          newUser.save (err) ->
            if err
              throw err
            return done(null, newUser)









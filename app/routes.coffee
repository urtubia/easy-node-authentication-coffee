module.exports = (app, passport) ->
  app.get '/', (req, res) ->
    if req.isAuthenticated()
      return res.redirect '/profile'
    res.render 'index.ejs'

  app.get '/logout', (req, res) ->
    req.logout()
    res.redirect '/'

  app.get '/profile', requireLoggedin, (req, res) ->
    res.render 'profile.ejs', { user: req.user }

  # Local login routes

  app.get '/login', (req, res) ->
    res.render 'login.ejs', { message: req.flash('loginMessage') }

  app.post '/login', passport.authenticate 'local-login', { successRedirect : '/profile',  failureRedirect : '/login',  failureFlash : true }

  app.get '/signup', (req, res) ->
    res.render 'signup.ejs', { message: req.flash('signupMessage') }

  app.post '/signup', passport.authenticate 'local-signup', { successRedirect : '/profile',  failureRedirect : '/signup',  failureFlash : true  }

  # Facebook login routes

  app.get '/auth/facebook', passport.authenticate 'facebook', { scope: 'email'}

  app.get '/auth/facebook/callback', passport.authenticate 'facebook', { successRedirect : '/profile',  failureRedirect : '/' }

  # Twitter login routes

  app.get '/auth/twitter', passport.authenticate 'twitter'

  app.get '/auth/twitter/callback', passport.authenticate 'twitter', { successRedirect : '/profile',  failureRedirect : '/' }

  # Google login routes

  app.get '/auth/google', passport.authenticate 'google', { scope: ['profile', 'email']}

  app.get '/auth/google/callback', passport.authenticate 'google', { successRedirect : '/profile',  failureRedirect : '/' }

requireLoggedin = (req, res, next) ->
  if req.isAuthenticated()
    return next()

  res.redirect '/'

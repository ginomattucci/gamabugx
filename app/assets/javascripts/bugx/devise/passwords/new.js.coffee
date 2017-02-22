Bugx.Devise ?= {}
Bugx.Devise.Passwords ?= {}

Bugx.Devise.Passwords.New =
  init: ->
    console.log 'entrou reset senha'
    console.log Konduto?
    console.log Konduto?.sendEvent?
    console.log '------'
    period = 300
    limit = 20 * 1e3
    nTry = 0
    intervalID = setInterval( ->
      clear = limit/period <= ++nTry
      if typeof(Konduto.sendEvent) != "undefined"
        Konduto?.sendEvent('page', 'password_reset')
        clear = true
      clearInterval(intervalID) if clear
    , period)

  modules: -> []

Bugx.Devise ?= {}
Bugx.Devise.Registrations ?= {}

Bugx.Devise.Registrations.New =
  init: ->
    console.log 'entrou cria conta'
    console.log Konduto?
    console.log Konduto?.sendEvent?
    console.log '------'
    period = 300
    limit = 20 * 1e3
    nTry = 0
    intervalID = setInterval(->
      clear = limit/period <= ++nTry
      if typeof(Konduto.sendEvent) != "undefined"
        Konduto?.sendEvent('page', 'account_creation')
        clear = true
      clearInterval(intervalID) if clear
    , period)

  modules: -> []

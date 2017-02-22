Bugx.Users ?= {}
Bugx.Users.Registrations ?= {}

Bugx.Users.Registrations.Edit =
  init: ->
    console.log 'entrou edit conta'
    console.log Konduto?
    console.log Konduto?.sendEvent?
    console.log '------'
    period = 300
    limit = 20 * 1e3
    nTry = 0
    intervalID = setInterval(->
      clear = limit/period <= ++nTry
      if typeof(Konduto.sendEvent) != "undefined"
        Konduto?.sendEvent('page', 'account')
        clear = true
      clearInterval(intervalID) if clear
    , period)

  modules: -> [
    Bugx.CpfMask
    Bugx.CepMask
    Bugx.PhoneMask
  ]

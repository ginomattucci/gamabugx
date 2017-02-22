Bugx.Pages ?= {}

Bugx.Pages.Home =
  init: ->
    console.log 'entrou home'
    console.log Konduto?
    console.log Konduto?.sendEvent?
    console.log '------'
    period = 300
    limit = 20 * 1e3
    nTry = 0
    intervalID = setInterval(->
      clear = limit/period <= ++nTry
      if typeof(Konduto.sendEvent) != "undefined"
        Konduto?.sendEvent('page', 'home')
        clear = true
      clearInterval(intervalID) if clear
    , period)

  modules: -> [
    Bugx.SmoothScroll
  ]

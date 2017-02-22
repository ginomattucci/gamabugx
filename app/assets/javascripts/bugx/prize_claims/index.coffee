Bugx.PrizeClaims ?= {}

Bugx.PrizeClaims.New =
  init: ->

  modules: -> [
    Bugx.CpfMask
    Bugx.CepMask
    Bugx.PhoneMask
  ]

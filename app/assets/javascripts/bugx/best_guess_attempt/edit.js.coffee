Bugx.BestGuessAttempt ?= {}

Bugx.BestGuessAttempt.Edit =
  init: ->
    maxSize = 80
    $('.js-optionListSelect').each ->
      if $(this).find('span').outerHeight() > maxSize
        maxSize = $(this).find('span').outerHeight()
    $('.js-optionListSelect label').css(height: maxSize + (if $('.js-optionListSelect img').length then 100 else 0))


  modules: -> [
    Bugx.CountUp
  ]

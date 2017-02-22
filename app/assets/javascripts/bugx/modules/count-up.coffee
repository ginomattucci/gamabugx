Bugx.CountUp =
  init: ->
    counter = $('.js-countup')
    start  = parseInt(counter.data('starts'))
    diff = ServerDate.now() - Date.now()
    start = start - diff

    counter.countdown
      since: new Date(start)
      layout: '{hnn}{sep}{mnn}{sep}{snn}'
    counter.countdown('option', { since: new Date(start) })

Bugx.Countdown =
  init: ->
    $('.js-spinner').addClass('u-hide')
    $('.js-countdown, .js-happensText').removeClass('u-hide')
    $counts = $('.js-countdown')
    $boxes  = $('.js-counterBox')

    $boxes.each (index, box) ->
      $box         = $(box)
      $count       = $box.find('.js-countdown')
      $happensText = $box.find('.js-happensText')
      $spinner     = $box.find('.js-spinner')
      $btn         = $box.find('.btn')
      $footer      = $box.find('.box-footer')

      $count.addClass('u-hide')

      if parseInt($box.data('ends'))
        return true

      checkUrl  = $box.data('verify-url')
      happensAt = parseInt($box.data('starts')) * 1000
      lastBid   = parseInt($box.data('last-bid')) * 1000 if $box.data('last-bid') != ''
      timer     = parseInt($box.data('timer')) * 1000

      if lastBid && happensAt < lastBid
        happensAt = lastBid

      period = new Date( (happensAt) + timer)

      if period < ServerDate.now()
        $.get(checkUrl)

      showCounter = (element) ->
        $footer.removeClass('-scheduled')
        $btn
          .removeClass('-btn-line-scheduled')
          .text('Click')
          .prop('value', 'Click')
          .prop('data-val', 'Click')
          .data('val', 'Click')
          .addClass('-btn-line-secondary') unless element.data('tournament') || element.data('subscribed')
        $happensText.addClass('u-hide')
        if !element.data('tournament') || element.data('started') || (element.data('subscribed') && element.data('data-starts') > 0)
          element.removeClass('u-hide')
        element.countdown
          timezone: element.data('timezone')
          onTick: (timer) ->
            if timer[0] == 0 && timer[1] == 0 && timer[2] == 0 && timer[3] == 0 && timer[4] == 0 && timer[5] == 0 && timer[6] == 5
              element.addClass('-warning')
          serverSync: ->
            ServerDate
          until: period,
          layout: '{mnn}{sep}{snn}'
          onExpiry: ->
            element.addClass('u-hide')
            $spinner.removeClass('u-hide')
            $.get(checkUrl, () ->
              $spinner.addClass('u-hide')
            )

      if happensAt > 0
        if happensAt < ServerDate.now()
          showCounter($count)
        else
          if (happensAt - ServerDate.now()) < 2147483647
            setTimeout(->
              showCounter($count)
            , parseInt(happensAt - ServerDate.now()))
      else
        $happensText.addClass('u-hide')

Bugx.BestGuessCountdown =
  init: ->
    $countDownBox = $('.js-countDown')
    $countDownBox.each ->
      countDownBox = $(this)
      $box = countDownBox.parents('.js-box')
      endsAt = parseInt(countDownBox.data('ends')) * 1000
      happensAt = parseInt(countDownBox.data('starts')) * 1000
      $spinner = $box.find('.js-spinner')
      $btn = $box.find('.btn')
      checkUrl = $box.data('verify-url')
      period = new Date(endsAt)
      reload = countDownBox.data('reload') == 'true'
      attemptEdit = countDownBox.data('attempt-edit')

      if endsAt < ServerDate.now()
        $.get(checkUrl)

      showCounter = (element) ->
        if element.data('tournament')
          $box.find('.js-happensText').hide()
        else
          $box.find('.js-hideScheduledBox, .js-hideWinnerBox, .js-hideFinishBox', '.js-hideFailBox').addClass('u-hide')
          $box.find('.js-hideActiveBox').removeClass('u-hide')
          element.parents('.-countdown').removeClass('u-hide')
        element.countdown
          timezone: element.data('timezone')
          onTick: (timer) ->
            if timer[0] == 0 && timer[1] == 0 && timer[2] == 0 && timer[3] == 0 && timer[4] == 0 && timer[5] == 0 && timer[6] == 5
              element.addClass('-warning')
          serverSync: ->
            ServerDate
          until: period
          format: 'HMS'
          layout: '{hnn}{sep}{mnn}{sep}{snn}'
          onExpiry: ->
            $spinner.removeClass('u-hide')
            element.parents('.-countdown').addClass('u-hide')
            $.get(checkUrl, () ->
              if attemptEdit
                window.setTimeout( ->
                    window.location = countDownBox.data('redirect-url')
                  , 2000
                )
              else if reload
                location.reload()
              else
                $spinner.addClass('u-hide')
            )


      if happensAt < ServerDate.now()
        showCounter(countDownBox)
      else
        if (happensAt - ServerDate.now()) < 2147483647
          setTimeout(->
            showCounter(countDownBox)
          , parseInt(happensAt - ServerDate.now()))

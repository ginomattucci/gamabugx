Bugx.EventSubscriber =
  init: ->
    $widget        = $('#pubnub-widget')
    widgetChannel  = $widget.data('channel')
    $headerCredits = $('.js-user-credits')

    loadOrtcFactory IbtRealTimeSJType, (factory, error) ->
      if (error != null)
        console?.log?("Factory error: " + error.message)
      else
        if factory != null
          client = factory.createClient()
          client.setClusterUrl('https://ortc-developers.realtime.co/server/ssl/2.1/')
          client.onConnected = (theClient) ->
            Bugx.Countdown.init()
            Bugx.BestGuessCountdown.init()
            theClient.subscribe widgetChannel, true, (theClient, channel, message) ->
              message = $.parseJSON(message)
              username = null
              discountCredits = false
              $box = null

              if message.type == 'AuctionBid'
                bid            = message
                $box           = $("#bidbox-#{bid.auction.id}")
                $user          = $box.find('.js-currentWinner')
                $rank          = $box.find('.js-rankingList')
                $btn           = $box.find('.js-btn-bid-cost')
                $value         = $box.find('.js-priceValue')
                $numberBids    = $('.js-numberBids')
                $discount      = $box.find('.js-discount')
                username       = $box.data('username')
                auctionStarted = (bid.happens_at) > ((parseInt($box.data('starts')) * 1000))
                timer          = parseInt($box.data('timer')) * 1000

                $user.text(if bid.user then bid.user.username else '---')
                $value.text("#{(bid.auction.value / 100).toFixed(2)}").priceFormat()
                $numberBids.text(if bid.auction.tournament then bid.auction.number_of_players else bid.auction.value)
                $discount.text("#{bid.auction.discount_percentage}%")

                # blink the time when has a new bid
                if bid.blink
                  $value.addClass('blink-red')
                  setTimeout(->
                    $value.removeClass('blink-red')
                  , 500)

                if bid.user && bid.auction.attendees && !bid.auction.finished
                  $rank.prepend($('<li></li>', text: bid.user.username))


                if auctionStarted
                  $box.find('.js-countdown').removeClass('u-hide').removeClass('-warning').show().countdown('option', { until: new Date(bid.happens_at + timer) })
                  btnValue = $btn.data('default-val') || 'Click'
                else
                  btnValue = $btn.data('default-val') || 'Agendado'

                if $box.data('username') == bid.user.username
                  $btn.removeClass '-btn-line-scheduled'

                # Check attempts and hide/show buy button
                if bid.auction.tournament && bid.auction.existing_attempts[$box.data('username')] >= 1 && $box.data('username') == bid.user.username
                  if bid.credits_remaining == 0
                    discountCredits = true
                    $box.find('.js-btn-bid-cost').hide()
                    if bid.auction.max_attempts > bid.auction.existing_attempts[$box.data('username')]
                      $box.find('.js-RebuyModal').first().removeClass('u-hide').show()
                    else
                      $box.find('.js-endRebuy').removeClass('u-hide').show()
                  else
                    $box.find('.js-endRebuy').addClass('u-hide')
                    $box.find('.js-RebuyModal').addClass('u-hide')
                    $box.find('.js-btn-bid-cost').show()

                # Check if the user isn't winning in the schedule
                if $box.data('username') != bid.user.username
                  $btn.removeClass('-btn-success').text(btnValue).val(btnValue).data('val', btnValue)
                else
                  $btn.addClass('-btn-success').text('Ganhando').val('Ganhando').data('val', 'Ganhando')

                # Check if the auction was sold
                if bid.auction.sold
                  # Show winner
                  if $box.data('username') == bid.user.username
                    auctionEndClass = '.js-hideWinnerBox'
                  # Check loser
                  else
                    auctionEndClass = '.js-hideFinishBox'
                  $box.find(auctionEndClass).removeClass('u-hide')
                  $box.find('.js-boxFooter').addClass('u-hide')
                # Check if the bid ends
                else if bid.auction.finished
                  $box.find('.js-hideFailBox').removeClass('u-hide')
                  $box.find('.js-boxFooter').addClass('u-hide')
                else
                  if bid.user && $box.data('username') == bid.user.username
                    $box.data('subscribed', true)
                  else
                    $user.removeClass('-winning')

                  discountCredits = true

              else if message.type == 'Auction'
                auction = message
                $box = $("#bidbox-#{auction.id}")
                $rank = $box.find('.js-rankingList')
                $spinner = $box.find('.js-spinner')
                if auction.tournament
                  $box.find('.js-Players span').text(auction.number_of_players)
                  if auction.joined && !auction.rebuy && auction.existing_attempts && Object.keys(auction.existing_attempts).length
                    $rank.empty()
                    $rank.prepend($('<li></li>', html: '&nbsp;'))
                    $rank.prepend($('<li></li>', html: '<strong>Participantes:</strong>'))
                    $(Object.keys(auction.existing_attempts)).each(->
                      $rank.append($('<li></li>', text: this))
                    )

                  if auction.joined && auction.number_of_players == auction.players
                    timer = parseInt($box.data('timer')) * 1000
                    element = $box.find('.js-countdown')
                    element.removeClass('u-hide')
                    $box.find('.js-boxFooter').removeClass('-scheduled')
                    element.countdown
                      timezone: element.data('timezone')
                      onTick: (timer) ->
                        if timer[0] == 0 && timer[1] == 0 && timer[2] == 0 && timer[3] == 0 && timer[4] == 0 && timer[5] == 0 && timer[6] == 5
                          element.addClass('-warning')
                      serverSync: ->
                        ServerDate
                      until: new Date( Date.now() + timer),
                      layout: '{mnn}{sep}{snn}'
                      onExpiry: ->
                        element.addClass('u-hide')
                        $spinner.removeClass('u-hide')
                        $.get(checkUrl, () ->
                          $box.find('.js-spinner').addClass('u-hide')
                        )
                    $box.find('.js-Players').hide()
                    $box.find('.js-btn-bid-cost.subscribe').remove()
                    $box.find('.js-btn-bid-cost.u-hide').removeClass('u-hide') if $box.data('subscribed')
                    $box.find('.js-cancelAttemptBtn').hide()
                    if auction.existing_attempts[$widget.data('username')]? && !auction.rebuy
                      $('.flash').remove()
                      $('body').prepend(
                        $('<div></div>', {
                          class: 'flash -game_start',
                          html: "<a target=\"_blank\" href=\"#{auction.url}\">O torneio #{auction.title} começou. Clique aqui para jogar!</a> <span class=\"flash-close\">&times;</span>"
                        })
                      )
                      Bugx.Flash.init(15000)
                      $('.js-gameStarted').addClass('on')
                    unless $box.data('subscribed')
                      $box.find('.js-FullRoom').removeClass('u-hide')
                  if $box.data('username')?.length
                    maxAttempt = $("#auction-modal-#{auction.id}").find('.js-maxAttempts')
                    if auction.existing_attempts[$box.data('username')] >= 1
                      maxText = parseInt(maxAttempt.data('attempts')) - auction.existing_attempts[$box.data('username')]
                      maxText = 'Este é seu último rebuy' if maxText == 0
                      maxAttempt.text(maxText)

                if auction.canceled
                  $box.find('.js-hideCanceledBox').removeClass('u-hide')
                  $box.find('.js-boxFooter').addClass('u-hide')
                  $box.find('.js-countdown').countdown('pause')
                  $box.find('.js-hideFailBox').addClass('u-hide')

              else if message.type == 'BestGuessAttempt'
                $box            = $("#best-guess-#{message.best_guess.id}")
                $btn            = $box.find('.btn')
                $value          = $box.find('.js-priceValue')
                username        = $box.data('username')
                $rank           = $('.js-rankingList')
                $numberAttempts = $('.js-numberAttempts')

                $value.text("#{(message.best_guess.value / 100).toFixed(2)}").priceFormat()
                userInList = $rank.find('li').filter( ->
                  $(this).text().trim() == message.user.username
                ).length
                $rank.prepend($('<li></li>', text: message.user.username)) unless userInList
                $numberAttempts.text(message.best_guess.number_of_players || message.best_guess.value)
                if message.best_guess.tournament
                  $box.find('.js-Players span').text(message.best_guess.number_of_players)
                  $(".js-best-guess-#{message.best_guess.id}.js-PlayerCountHighlight .js-Players span").text(message.best_guess.number_of_players)
                  if message.joined && message.best_guess.number_of_players == message.best_guess.players
                    if $box.parents('.row').first().css('backgroundColor') == "rgb(209, 209, 209)"
                      $box.parents('.row').first().css('backgroundColor', '')
                    $box.find('.js-cancelAttemptBtn').hide()
                    $box.find('.js-continueEditButton').removeClass('u-hide')
                    $box.find('.js-btn-bid-cost').hide()
                    $box.find('.js-followGame').removeClass('u-hide')
                    element = $box.find('.js-countDown.js-withScheduled, .js-countDown.js-withActive')
                    timer = parseInt(element.data('end-step')) * 1000 * 60
                    element.removeClass('u-hide')
                    element.parents('.js-parent').removeClass('u-hide')
                    $box.find('.js-boxFooter').removeClass('-scheduled')
                    $box.find('.js-Players').addClass('u-hide')
                    $spinner = $box.find('.js-spinner')
                    if element.data('tournament')
                      $box.find('.js-happensText').hide()
                      $box.find('.js-hideScheduledBox, .js-hideWinnerBox, .js-hideFinishBox', '.js-hideFailBox').addClass('u-hide')
                      $box.find('.js-hideActiveBox').removeClass('u-hide')
                    else
                      $box.find('.js-hideScheduledBox, .js-hideWinnerBox, .js-hideFinishBox', '.js-hideFailBox').addClass('u-hide')
                      $box.find('.js-hideActiveBox').removeClass('u-hide')
                      element.parents('.-countdown').removeClass('u-hide')
                    element.countdown('option', { until: new Date( Date.now() + timer) })
                    if message.best_guess.existing_attempts[$widget.data('username')]?
                      $('.flash').remove()
                      $('body').prepend(
                        $('<div></div>', {
                          class: 'flash -game_start',
                          html: "<a target=\"_blank\" href=\"#{message.best_guess.url}\">O torneio #{message.best_guess.title} começou. Clique aqui para jogar!</a> <span class=\"flash-close\">&times;</span>"
                        })
                      )
                      Bugx.Flash.init(15000)
                      $('.js-gameStarted').addClass('on')

                    setTimeout(->
                      $.get($box.data('verify-url'))
                    , parseInt(ServerDate.now() + 60000))
                if message.user && username == message.user.username
                  $btn.addClass('u-hide')
                  $box.find('.js-followGame').removeClass('u-hide')
                  discountCredits = true

              else if message.type == 'BestGuess'
                bestGuess    = message
                $box         = $("#best-guess-#{bestGuess.id}")
                $boxValue    = $box.find('.js-priceValue')
                $winnerBox   = $box.find('.js-hideWinnerBox')
                username = $box.data('username')

                if bestGuess.finished
                  $boxValue.text("#{(bestGuess.value / 100).toFixed(2)}").priceFormat()
                  if $('.js-tabHandle').length && $('.js-tabContentHandle').length && $box.data('feedback').length
                    $.get($box.data('feedback'), (html) ->
                      $('#winner').remove()
                      $('#winnerTab').remove()
                      $('.js-tab-body').removeClass('is-open')
                      $('.js-tab-toggle').removeClass('is-active')
                      $('.js-tabHandle').append(
                        $('<div></div>', class: 'column -sm-1-4').append(
                          $('<button></button>', class: 'btn btn-tab is-active -btn-block js-tab-toggle', data_target: '#winner', text: 'Vencedor')
                        )
                      )
                      $('.js-tabContentHandle').append(
                        $('<div></div>', class: 'column -md-fill js-tab-body is-open u-centered', id: 'winner').append(
                          $('<div></div>', id: "gabarito-#{bestGuess.id}", html: html)
                        )
                      )
                    )
                  if bestGuess.winner
                    if bestGuess.winner.username == username
                      $winnerBox.removeClass('u-hide')
                    else
                      $box.find('.js-hideScheduledBox').addClass('u-hide')
                      $box.find('.js-currentWinner').text(bestGuess.winner.username)
                      $box.find('.js-discount').text("#{bestGuess.discount_percentage}%")
                      $box.find('.js-hideFinishBox').removeClass('u-hide')
                  else
                    $box.find('.js-hideFailBox').removeClass('u-hide')
                  $box.find('.js-hideActiveBox').addClass('u-hide')

              # for all messages
              if message.user && message.user.username == username && discountCredits
                if message.credits_remaining != null || message.auction?.tournament
                  $box.find('.js-creditsAttempt').text(message.credits_remaining) if message.credits_remaining != null
                else
                  $headerCredits.each ->
                    $(this).text(parseInt($(this).text()) - message.value_in_credits)
          client.connect $widget.data('key'), 'token'
          $(document).one 'page:before-change', ->
            client.unsubscribe(widgetChannel)

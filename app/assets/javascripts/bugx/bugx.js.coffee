window.Bugx =
  configs:
    turbolinks: true # True to use initjs with Turbolinks by default.
    pjax: false # True to use initjs with pjax by default.
    respond_with: # To not use respond_with, just set false.
      'Create': 'New' # Respond the Create action with the New.
      'Update': 'Edit' # Respond the Update action with the Edit.

  initPage: ->
    # If you're using the Turbolinks or pjax and you need run a code once, put something here.
    # if you're not using the turbolinks or pjax, there's no difference between init and initPage.

  init: ->
    $konduto = $('#konduto-widget')
    if $konduto.data('user').length
      console.log 'fazendo setCustomerID'
      console.log Konduto?
      console.log Konduto?.sendEvent?
      console.log '------'
      period = 300
      limit = 20 * 1e3
      nTry = 0
      intervalID = setInterval(->
        clear = limit/period <= ++nTry
        if typeof(Konduto.setCustomerID) != "undefined"
          Konduto?.setCustomerID($konduto.data('user'))
          clear = true
        clearInterval(intervalID) if clear
      , period)
    $('.slider').slick({
      dots: true
      arrows: false
      autoplay: true
      autoplaySpeed: 8000
    })

    $toggleMenu = $('.menu-toggle')
    $toggleMenu.on('click', ->
      $('.menu.-mobile').toggleClass('is-open')
    )

    $('.js-toggle-search').removeClass('btn').removeClass('btn-default')

    $bidAction = $('.js-box').find('.js-bid-action')
    $bidBtn = $bidAction.find('.js-btn-bid-cost')
    bidCost = $bidAction.data('costing')
    btnDefaultValue = null

    # Disable in small screens
    if $(window).width() > 975
      textChanged = false
      $bidBtn.on('mouseover', ->
        btnDefaultValue = $(this).html()
        $bidAct = $(this).parents('.js-bid-action')
        val = $bidAct.data('costing')
        increaseValue = $bidAct.data('increase')
        return if $bidAct.data('subscribed')
        textChanged = true
        $(this).html(
          if $bidAct.data('tournament') || $bidAct.data('type') == 'BestGuess'
            if $bidAct.data('type') == 'Auction'
              "<span style=\"line-height: 14px;font-size:14px;display:block;margin-top:2px\">S<i class=\"fa fa-bitcoin\" style=\"pointer-events: none; font-size:14px\"></i>#{val}</span><span style=\"font-size:10px;display:block\">#{if $bidAct.data('tournament') then " = #{$bidAct.data('tournament')} créditos no jogo" else ''}</span>"
            else
              "<span style=\"line-height: 14px;font-size:14px;display:block;margin-top:2px\">S<i class=\"fa fa-bitcoin\" style=\"pointer-events: none; font-size:14px\"></i>#{val}</span><span style=\"font-size:10px;display:block\"> +#{increaseValue}/palpite</span>"
          else
            "<span style=\"line-height: 14px;font-size:14px;display:block;margin-top:2px\">S<i class=\"fa fa-bitcoin\" style=\"pointer-events: none; font-size:14px\"></i>#{val}</span><span style=\"font-size:10px;display:block\"> +#{increaseValue}/click</span>"
        )
      )

      $bidBtn.on('mouseout', ->
        if textChanged
          $(this).html($(this).data('val') || btnDefaultValue)
        textChanged = false
      )

    $flash = $('.flash')
    $('.js-bid-action form').on('ajax:error', (event, xhr, status, error) ->
      if $flash.length == 0
        $flash = $('<div></div>', class: 'flash -alert')
      else
        $flash.removeClass('-notice').addClass('-alert')
      $flash.html(JSON.parse(xhr.responseText).errors.join('; '))
      $('body').prepend($flash)
      $flash.fadeIn()
      setTimeout( ->
        $flash.fadeOut()
      , 3000)
    )

    $('.js-tab-toggle').on('click', ->
      target = $(this).data('target')
      $target = $(target)

      $('.js-tab-body').removeClass('is-open')
      $('.js-tab-toggle').removeClass('is-active')
      $(this).addClass('is-active')
      $target.addClass('is-open')
    )

  modules: ->
    [
      Bugx.Flash
      Bugx.Modal
      Bugx.EventSubscriber
    ]

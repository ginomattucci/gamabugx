Bugx.Flash =
  init: (time = 5000) ->
    $flash      = $('.flash')
    $flashClose = $flash.find('.flash-close')

    setTimeout( ->
      $flash.slideDown()
    , 100)
    if $flash.length > 0
      setTimeout( ->
        $flash.slideUp()
      , time)
    $flashClose.on 'click', ->
      $flash.slideUp()

Bugx.Modal =
  init: ->
    # TODO: Write as a class and use in others projects
    $overlay = $('.is-modalOpen')
    $modalWrapper = $('.modal-wrapper')
    $modal   = $('.modal')
    $html    = $('html')
    $action  = $('[data-trig="modal"]')
    $close   = $('[data-close="modal"]')
    $remotes = $('[data-remote]')
    window.defaultBodyPadding = document.body.style.paddingRight || ''

    checkScroll = (target) ->
      htmlTarget = target.find('.modal')[0]
      if document.body.clientWidth < window.innerWidth
        document.body.style.paddingRight = "#{getScrollbar()}px"

    getScrollbar = () ->
      scrollDiv = document.createElement("div")
      scrollDiv.className = "scrollbar-measure"
      document.body.appendChild(scrollDiv)
      scrollbarWidth = scrollDiv.offsetWidth - scrollDiv.clientWidth
      scrollbarWidth

    # Close modal
    closeModal = () ->
      $modalWrapper.removeClass('is-open')
      $html.removeClass('is-modalOpen')
      document.body.style.paddingRight = defaultBodyPadding

    getTarget = (element) ->
      target = element.data('target')
      $target = $(target)
      $target

    # Show the modal and manipulate remote
    showModal = (element) ->
      $target = getTarget(element)
      checkScroll($target)
      $html.toggleClass('is-modalOpen')
      $target.toggleClass('is-open')

    # Load remote
    loadRemote = (element) ->
      remote = element.data('remote')
      $target = getTarget(element)

      $target
        .find('.modal-body')
        .load(remote, (response, status, xhr) ->
          if status == 'error'
            $(this).html('Error ' + xhr.status + ' ' + xhr.statusText)
        )

    # Preload ours remotes
    preLoadRemote = () ->
      if $remotes.length == 0
        return
      $.each($remotes, (index, remote) ->
        loadRemote($(remote))
      )

    preLoadRemote()

    $action.on('click', (e) ->
      e.preventDefault()
      showModal($(this))
    )

    # Close modal when click on x
    $close.on('click', (e) ->
      closeModal()
    )

    # Close modal when click outside
    $modalWrapper.on('click', (e) ->
      closeModal()
    )

    $modal.on('click', (e) ->
      e.stopPropagation()
    )

    # Click modal on ESC key
    $html.on('keyup', (e) ->
      if e.keyCode == 27
        closeModal()
    )


Bugx.Plans ?= {}

Bugx.Plans.Index =
  init: ->
    widget = $('#iugu-widget')
    Iugu.setAccountID(widget.data('account'))
    if widget.data('environment') != 'production'
      Iugu.setTestMode(true)
    Iugu.setup()

    $paymentForm = $('.js-paymentForm')

    numeroDoCartao = $paymentForm.find('[data-iugu="number"]')
    valorCVV = $paymentForm.find('[data-iugu="verification_value"]')
    valorNome = $paymentForm.find('[data-iugu="full_name"]')
    valorData = $paymentForm.find('[data-iugu="expiration"]')

    numeroDoCartao.on('keyup', ->
      if Iugu.utils.validateCreditCardNumber(numeroDoCartao.val())
        $(this).parents('.planForm-input').removeClass('is-errored')
      else
        $(this).parents('.planForm-input').addClass('is-errored')
    )

    valorCVV.on('keyup', ->
      brand = Iugu.utils.getBrandByCreditCardNumber(numeroDoCartao.val())
      if Iugu.utils.validateCVV(valorCVV.val(), brand)
        $(this).parents('.planForm-input').removeClass('is-errored')
      else
        $(this).parents('.planForm-input').addClass('is-errored')
    )

    valorNome.on('keyup', ->
      if /.+\s.+/.test(valorNome.val())
        $(this).parents('.planForm-input').removeClass('is-errored')
      else
        $(this).parents('.planForm-input').addClass('is-errored')
    )

    valorData.on('keyup', ->
      if Iugu.utils.validateExpirationString(valorData.val())
        $(this).parents('.planForm-input').removeClass('is-errored')
      else
        $(this).parents('.planForm-input').addClass('is-errored')
    )


    $('.js-paymentForm').submit (e) ->
      $('.js-kondutoUser').val(Konduto?.getVisitorID())
      if $(this).find('#purchase_payment_method_credit_card').prop('checked')
        e.preventDefault()
        form = $(this)
        tokenResponseHandler = (data) ->
          if (data.errors)
            console?.log?(data.errors)
          else
            $('.js-paymentToken').val(data.id)
            form.get(0).submit()
        Iugu.createPaymentToken(this, tokenResponseHandler)
        false

    $('.paymentMethod').find('label').on('click', () ->
      if $(this).find('#purchase_payment_method_bank_slip').prop('checked')
        $('.js-credit-card-wrapper').slideUp()
      else
        $('.js-credit-card-wrapper').slideDown()
    )

    checkPlanPrice = ->
      price = $('.js-radio-toggle-wrapper').find('label.is-active').find('.js-plans-cost').text().replace(/\./g, '').replace(',', '.')
      instalment = $('#purchase_months').val() || 1
      finalPrice = parseFloat(price, 10) / instalment
      finalPrice = Math.round(finalPrice * 100) / 100
      $('.js-price-value')
        .find('.months').text(instalment)
      $('.js-price-value')
        .find('.price').text(finalPrice.toFixed(2)).priceFormat()
      price

    changeSelectValue = ->
      $('#purchase_months option').each(->
        instalment = $(this).val()
        return if instalment == ''

        price = checkPlanPrice()
        finalPrice = parseInt(price, 10) / instalment
        finalPrice = Math.round(finalPrice * 100) / 100

        $(this).text(finalPrice.toFixed(2)).priceFormat()
        $(this).text("#{instalment}x de #{$(this).text()}")
      )

    $('#purchase_months').on('change', ->
      checkPlanPrice()
    )

    $('.js-radio-toggle-wrapper').find('input[type="radio"]').on('click', () ->
      if $(this).prop('checked')
        $label = $(this).parents('label')
        $btn = $label.find('.btn')
        $wrapper = $(this).parents('.js-radio-toggle-wrapper')

        $wrapper.find('label').removeClass('is-active')
        $wrapper.find('.btn').removeClass('-btn-inverse').addClass('-btn-line-primary')
        $btn.removeClass('-btn-line-primary').addClass('-btn-inverse')
        $label.addClass('is-active')
        checkPlanPrice()
        changeSelectValue()
    )
    $('#purchase_payment_method_credit_card').trigger('click')

    $('.js-plan-to-scroll').on('click', ->
      console.log 'entrou checkout'
      console.log Konduto?
      console.log Konduto?.sendEvent?
      console.log '------'
      period = 300
      limit = 20 * 1e3
      nTry = 0
      intervalID = setInterval(->
        clear = limit/period <= ++nTry
        if typeof(Konduto.sendEvent) != "undefined"
          Konduto?.sendEvent('page', 'checkout')
          clear = true
        clearInterval(intervalID) if clear
      , period)
      $('html,body').animate({
          scrollTop: $('#plans-payment').offset().top
      }, 500)
    )
    console.log 'entrou product'
    console.log Konduto?
    console.log Konduto?.sendEvent?
    console.log '------'
    period = 300
    limit = 20 * 1e3
    nTry = 0
    intervalID = setInterval(->
      clear = limit/period <= ++nTry
      if typeof(Konduto.sendEvent) != "undefined"
        Konduto?.sendEvent('page', 'product')
        clear = true
      clearInterval(intervalID) if clear
    , period)


  modules: -> [
    Bugx.CpfMask
    Bugx.CepMask
    Bugx.PhoneMask
  ]

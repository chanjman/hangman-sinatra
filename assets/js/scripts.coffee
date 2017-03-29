hangParts = ['.pole', '.level-beam', '.cross-beam', '.down-beam', '.head', '.lant', '.rant', '.body', '.arm', '.leg']

$ ->
  if window.location.href.match(/new/)
    $.each hangParts, (key, value) ->
      $(value).css(opacity: '0.2')

$ ->
# Get the name
  textInput = document.getElementById('name-form')
  timeout = null

  textInput.onkeyup = (e) ->
    clearTimeout timeout
    timeout = setTimeout((->
      if $.trim($('#name-form').val())
         $('#play').fadeIn(200)
      else
        $('#play').fadeOut(200)
    ), 500)

$ ->
# Choose letter of alphabet
  $('.alphabet__letter span').click ->
    letter = $(this).text()
    $(this).parent().addClass('alphabet__letter--used')

    $.ajax '/guess',
      type: 'POST'
      data: { guess: letter}
      success: (data) ->
        hangData = JSON.parse(data)
        hangMoves = hangData['remaining_moves']
        hangGuessed = hangData['guessed_letters']
        hangOver = hangData['game_over']


        i = $('.letter').length - 1
        while i >= 0
          $('.letter span').eq(i).html(hangGuessed[i])
          i--

        $('.remaining_moves span').text(hangMoves)
        $('.remaining_moves span').css(color: 'rgb(149, 46, 46)') if hangMoves < 4

        altMoves = 9 - hangMoves

        $(hangParts[altMoves]).css(opacity: '1') if altMoves >= 0

        alert 'Game over' if hangOver

$ ->
# Disable enter submit on forms
  $(document).on 'keyup keypress', 'form input[type="text"]', (e) ->
    if e.keyCode == 13 || e.keycode == 169
      e.preventDefault()
      return false
    return

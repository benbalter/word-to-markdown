# Select text
# Source: http://stackoverflow.com/questions/985272/jquery-selecting-text-in-an-element-akin-to-highlighting-with-your-mouse
jQuery.fn.selectText = ->
  doc = document
  element = this[0]
  range = undefined
  selection = undefined
  if doc.body.createTextRange
    range = document.body.createTextRange()
    range.moveToElementText element
    range.select()
  else if window.getSelection
    selection = window.getSelection()
    range = document.createRange()
    range.selectNodeContents element
    selection.removeAllRanges()
    selection.addRange range

$ ->
  $("#doc").change ->
    $("#submit").click()

  $(".md-preview").click ->
    $(".md-preview").selectText()

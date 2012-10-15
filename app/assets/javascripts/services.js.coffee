# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  service_type = $('#service_service_type')
  update_service_fields = ->
    type = service_type.val()
    $('.service_settings').hide()
    $("##{type}_form").show()
    
  service_type.bind 'change', update_service_fields
  update_service_fields()

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('#metric_search').liveUpdate('#metrics').focus()

  $('.sparklines').sparkline 'html',
    height: '22px', width: '130px',
    chartRangeMinX: 0,
    spotColor: '#000',
    minSpotColor: null,
    maxSpotColor: null,
    fillColor: '#E6F2FA', lineColor: '#0077CC', disableInteraction: true

$(function(){

  $('body').removeClass('no-js').addClass('js');

  $('.waypoint').waypoint(function(direction) {
    $(this).addClass('animate');
  }, { 
    offset: '60%' 
  });
});
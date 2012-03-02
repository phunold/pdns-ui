/*-------------------------*/
/* SIMPLE jQUERY TOOLTIP   */
/* VERSION: 1.1            */
/* AUTHOR: jon cazier      */
/* EMAIL: jon@3nhanced.com */
/* WEBSITE: 3nhanced.com   */
/*-------------------------*/
$(document).ready(function() {
  $(‘.tooltip’).hover(
    function() {
    this.tip = this.title;
    $(this).append(
     ‘<div class="ttWrapper">’
        +‘<div class="ttTop"></div>’
        +‘<div class="ttMid">’
          +this.tip
        +‘</div>’
        +‘<div class="ttBtm"></div>’
      +‘</div>’
    );
    this.title = "";
    this.width = $(this).width();
    $(this).find(‘.ttWrapper’).css({left:this.width-22})
    $(‘.ttWrapper’).fadeIn(300);
  },
    function() {
      $(‘.ttWrapper’).fadeOut(100);
      $(this).children().remove();
        this.title = this.tip;
      }
  );
});


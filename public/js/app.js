$(document).ready(function() {
  $('.dropdown-toggle').dropdown();
  $('body').tooltip({'selector':"[rel=tooltip]", 'placement':'bottom'});
  $('.to_modal').click(function(e) {
    e.preventDefault();
    var href = $(e.target).attr('href');
    if (href.indexOf('#') == 0) {
        $(href).modal('open');
    } else {
        $.get(href, function(data) {
            $('<div class="modal fade" >' + data + '</div>').modal();
        });
    }
  });
});

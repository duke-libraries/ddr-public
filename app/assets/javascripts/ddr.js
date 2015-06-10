// Trigger Bootstrap UI actions
// See http://getbootstrap.com/javascript/

$(function () {
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover({ trigger: 'hover'});
  $('[data-toggle="popover-click"]').popover({ trigger: 'click'});  
});

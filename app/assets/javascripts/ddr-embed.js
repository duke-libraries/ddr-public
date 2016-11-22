$(function () {
  // Auto-select the embed code or permalink when they have focus
  $("#copyable-embed-code, #copyable-permalink").focus(function() {
    var $this = $(this);
    $this.select();
    $this.mouseup(function() {
      $this.unbind("mouseup");
      return false;
    });
  });

  $("#iframe-embed-info-button").click(function() {
    if ($(this).attr('aria-expanded') == 'true') {
      $('.iframe-embed-title').addClass('truncated-title');
    } else {
      $('.iframe-embed-title').removeClass('truncated-title');      
    };
    $("#iframe-share-info").removeClass('in');
    $("#iframe-embed-share-button").attr('aria-expanded','false');
  });

  $("#iframe-embed-share-button").click(function() {
    $("#iframe-embed-info").removeClass('in');
    $("#iframe-embed-info-button").attr('aria-expanded','false');
  });
});

$(function () {

  // Expand & collapse interactive transcript
  $("#transcript-expand").click(function(e) {
    e.preventDefault();
    if ($(this).hasClass('collapsed')) {

      $('#interactive-transcript').animate({
          height: $('#interactive-transcript').get(0).scrollHeight
      }, 1500, function(){
          $(this).height('auto');
      });
      $(this).data('state','expanded');
    } else {
      $('#interactive-transcript').animate({ height: 300 }, 1500 );
      $(this).data('state','collapsed');
    }
    $(this).toggleClass("collapsed");
  });

  // Change the transcript showing when the playlist's current track changes
  jwplayer().on('playlistItem', function(e){
    current_track = jwplayer().getPlaylistIndex();
    current_transcript_id = "#tr-"+current_track;
    $('#interactive-transcript-tabs.nav-tabs a[href="' + current_transcript_id + '"]').tab('show');
  });


  // Jump the player to the point in the transcript clicked
  // Make the entire cue row clickable
  $('.tr-cue').click(function(e) {
    e.preventDefault();
    seconds = $(this).data('jump-sec');
    cue_track = $(this).closest('.tr-pane').data('track');

    if (jwplayer().getState() !== 'playing') {
      jwplayer().stop;
      jwplayer().playlistItem(cue_track);
    }

    jwplayer().seek(seconds);

  });

  // Highlight the currently-playing cue while media plays
  jwplayer().on('time', function(e) {
    current_track = jwplayer().getPlaylistIndex();
    seconds = Math.floor(e.position);
    if($("#tr-"+current_track+"-cue-"+seconds).length !== 0) {
      $('.tr-cue').removeClass('current-cue');
      $('.tr-pane[data-track="'+current_track+'"] [data-jump-sec="'+seconds+'"]').addClass('current-cue');
    }        
  });


});

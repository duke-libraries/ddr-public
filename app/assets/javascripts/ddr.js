// Trigger Bootstrap UI actions
// See http://getbootstrap.com/javascript/

$(function () {
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover({ trigger: 'hover'});
    $('[data-toggle="popover-click"]').popover({ trigger: 'click'});
    $('[data-toggle="fade-element"]').hover(function(e){
        $(('#')+$(this).attr('data-target-id')).fadeToggle();
    });


    // Activate tabs
    $('.nav-tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    })

    // Smooth scroll to all anchors
    $('a[href*=#]:not([href=#])').click(function() {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'')
            || location.hostname == this.hostname) {

            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
                if (target.length) {
                    $('html,body').animate({
                        scrollTop: target.offset().top
                    }, 750);
                    return false;
            }
        }
    });


    // Popover metadata from Gallery (Grid) View of Related Items
    $('#related-items #documents.gallery .thumbnail-wrapper').popover({
      trigger: 'hover',
      container: '#related-items',
      viewport: '#content',
      content: function(){
        return $(this).find('.document-metadata').html();
      },
      placement: 'auto bottom',
      html: true
    });


});



$( document ).ready(function() {
    
    // Apply Bootstrap button dropdown style to search select dropdown
    $('.selectpicker').selectpicker();
    
    // Changes the search form's action URL to the selected dropdown option
    $(".search_scope").change(function() {
        var action = $(this).val();
        $(".search-query-form").attr("action", action);
    });
});








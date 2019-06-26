// Trigger Bootstrap UI actions
// See http://getbootstrap.com/javascript/

$(function () {
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover({ trigger: 'hover'});
    $('[data-toggle="popover-click"]').popover({ trigger: 'focus'});
    $('[data-toggle="popover-click"]').on('click', function(e) {e.preventDefault(); return true;});
    $('[data-toggle="fade-element"]').hover(function(e){
        $(('#')+$(this).attr('data-target-id')).fadeToggle();
    });

    // Activate tabs
    $('.nav-tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });

    // Link to activate tab from in page, e.g., another tab's content
    $('a[data-toggle="tab"]:not(.nav-tabs *)').click(function (e) {
        e.preventDefault();
        $('a[href="' + $(this).attr("href") + '"]').tab('show');
    });

    // Bookmarkable tabs
    $(document).ready(function() {
        // show active tab on reload
        if (location.hash !== '') $('a[href="' + location.hash + '"]').tab('show');

        // remember the hash in the URL without jumping
        $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
           if(history.pushState) {
                history.pushState(null, null, '#'+$(e.target).attr('href').substr(1));
           } else {
                location.hash = '#'+$(e.target).attr('href').substr(1);
           }
        });
    });


    // Smooth scroll to all anchors
    $('a[href*="#"]:not([href="#"])').click(function() {
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

    // Enable popover from Download dropdown menu without closing it
    $(document).on('click', '#download-menu.dropdown-menu', function (e) {
      e.stopPropagation();
    });

    // Make js tree links active
    $('.directory-tree').on('activate_node.jstree', function(e,data){
        window.location.href = data.node.a_attr.href;
    });


    /* Check if a user has a touchscreen device and has touched it */
    window.addEventListener('touchstart', function onFirstTouch() {

      /* Turn off tooltips */
      $('[data-toggle="tooltip"]').tooltip('destroy');

      /* Add touch classes to certain elements for refined styles/scripts */
      $(".openseadragon-container").addClass('touch-enabled');

      window.removeEventListener('touchstart', onFirstTouch, false);
    }, false);


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

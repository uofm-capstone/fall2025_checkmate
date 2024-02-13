$(document).ready(function() {
    // Smooth scrolling for jump buttons
    function smoothScrollTo(target, offset = 0) {
        $('html, body').animate({
            scrollTop: target.offset().top - offset
        }, 1);
    }

    //
    // replace "60" (or any number) with the height of navbar in each function call
    // so the title isn't hidden behind the navbar when you navigate to an id (title) on the page
    //
    $('#btn-jump-to-tms').on('click', function() {
        smoothScrollTo($('#team-member-scores'), 60);
    });

    $('#btn-jump-to-cs').on('click', function() {
        smoothScrollTo($('#client-scores'), 60);
    });

    $('#btn-jump-to-tmr').on('click', function() {
        smoothScrollTo($('#team-member-responses'), 60);
    });

    $('#btn-jump-to-sqq').on('click', function() {
        smoothScrollTo($('#student-qualitative-questions'), 60);
    });

    $('#btn-jump-to-cqq').on('click', function() {
        smoothScrollTo($('#client-qualitative-questions'), 60);
    });

    $('#btn-jump-to-ghc').on('click', function() {
        smoothScrollTo($('#github-commits'), 60);
    });
});

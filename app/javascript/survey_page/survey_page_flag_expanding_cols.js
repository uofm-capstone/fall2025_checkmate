$(document).ready(function() {
    // Cache the expand-all button and collapsible elements
    let $expandAllButton = $(".expand-all-flag");
    let $collapsibles = $(".multi-collapse");

    $(".expand-all-flag").on("click", function() {
        // Determine the current state of "aria-expanded" for this button
        let isExpanded = $(this).attr("aria-expanded") === "true";
        // Toggle the "aria-expanded" attribute
        $(this).attr("aria-expanded", !isExpanded);
        // Change the button text based on the current state
        // $(this).text(isExpanded ? "Expand All" : "Collapse All");

        // Find all elements with the "multi-collapse" class
        $(".multi-collapse").each(function() {
            // Check if the element is present and visible
            if ($(this).length) {
                // Toggle the collapse state based on the button's state
                if (isExpanded) {
                    $(this).collapse('hide');
                } else {
                    $(this).collapse('show');
                }
            }
        });
    });
});

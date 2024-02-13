$(document).ready(function() {
    // Cache the expand-all button and collapsible elements
    let $expandAllButton = $(".expand-all");
    let $collapsibles = $(".multi-collapse");

    $expandAllButton.on("click", function() {
        let isExpanded = $expandAllButton.attr("aria-expanded") === "true";

        // Toggle the aria-expanded attribute of the expand-all button
        $expandAllButton.attr("aria-expanded", !isExpanded);

        // Toggle the text of the expand-all button based on the current state
        $expandAllButton.text(isExpanded ? "Expand All" : "Collapse");

        // Expand or collapse all collapsible elements based on the current state
        $collapsibles.collapse(isExpanded ? "hide" : "show");
    });

    // Restore the default behavior of individual expand buttons
    $collapsibles.each(function() {
        let $collapsible = $(this);
        let $expandButton = $collapsible.prev();

        $expandButton.on("click", function() {
            let isExpanded = $expandButton.attr("aria-expanded") === "true";
            $expandButton.attr("aria-expanded", !isExpanded);
            $collapsible.collapse(isExpanded ? "hide" : "show");
        });
    });
});

// View for our raceboxes
var SliderView = Backbone.View.extend({
    el: 'body',

    events: {
        "change .dropdown": "sliderDropdownChange"
    },

    // One of the option boxes that corresponds with a slider is changed
    sliderDropdownChange: function(ev) {
        var slider_div = $(ev.currentTarget).val()
        
        // Show the right slider and hide the others
        $('.'  + slider_div).show();
        $('.'  + slider_div).siblings().hide();

        // Reset slider
        var min_slider = $( "#slider-" + slider_div ).slider("option", "min");
        var max_slider = $( "#slider-" + slider_div ).slider("option", "max");
        $( "#slider-" + slider_div ).slider("values", 0, min_slider);
        $( "#slider-" + slider_div ).slider("values", 1, max_slider);

        // Reset values in selected categories object
        _.each( $('#dropdown-' + slider_div).siblings(), function (value, key) {
            var value = $(value).val();
            var min_value = $("#slider-" + value).slider("option", "min");
            var max_value = $("#slider-" + value).slider("option", "max");

            selected_categories[value] = [min_value, max_value];
        }, this);

        // Call slider
        $( "#slider-" + slider_div ).slider('option', 'change').call( $( "#slider-" + slider_div ) );
    }
});


// Create instance of router
var sliderview = new SliderView();
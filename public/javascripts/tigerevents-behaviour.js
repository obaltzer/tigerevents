Behaviour.register({
    'select#theme_selector': function(e) {
        e.onchange = function() {
            quicklink(e, 1);
        }
    }
});

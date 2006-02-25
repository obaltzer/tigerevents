Behaviour.register({
    'a#group_info': function(e) {
        e.onmouseover = function() {
           toolTipOn(getSiblingByClass(e, 'tooltip'));
        }
        e.onmouseout = function() {
           toolTipOff();
        }
    }
});

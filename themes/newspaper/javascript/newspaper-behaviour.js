if(browser.isGecko && !browser.isKonqueror || browser.isSafari 
    || browser.isOpera)
{
    myrules = {
        'ul#all_announcements_list': function(e)
        {
            new FadeItems(e);
        },
        
        'a#group_info_tooltip': function(e) {
            e.onmouseover = function() {
                toolTipOn(getSiblingByClass(e, 'tooltip'));
            };
            e.onmouseout = function() {
                toolTipOff();
            };
        }
   };
    Behaviour.register(myrules);
}
else
{
    setActiveStyleSheet('nofx', 1);
}
if(browser.isIE)
{
    setActiveStyleSheet('ie', 1);
}

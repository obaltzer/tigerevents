if(browser.isGecko && !browser.isKonqueror || browser.isSafari 
    || browser.isOpera)
{
    Behaviour.register({
        'ul#all_announcements_list': function(e)
        {
            new FadeItems(e);
        }
    });
}
else
{
    setActiveStyleSheet('nofx', 1);
}
if(browser.isIE)
{
    setActiveStyleSheet('ie', 1);
}

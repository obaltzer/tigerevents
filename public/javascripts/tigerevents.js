/* tigerevents.js
 *
 * This file contains TigerEvents specific JavaScript functions used
 * throughout the view.
 */

/* This is a quick tooltip hack, based on
 * http://www.webmatze.de/webdesign/javascript/tooltips.htm */
tooltip_obj = null;
document.onmousemove = updateTooltip;

function updateTooltip(e)
{
    x = (document.all) ? window.event.x + document.body.scrollLeft 
                       : e.pageX;
    y = (document.all) ? window.event.y + document.body.scrollTop
                       : e.pageY;
    if(tooltip_obj)
    {
        tooltip_obj.style.left = (x + 20) + "px";
        tooltip_obj.style.top = (y + 20) + "px";
    }
}

function ttOn(id)
{
    tooltip_obj = document.getElementById(id);
    tooltip_obj.style.display = "block";
}

function ttOff()
{
    tooltip_obj.style.display = "none";
    tooltip_obj = null;
}

function mail(b, a)
{
    window.location = 'mailto:' + a + '@' + b;
}

function toggle(elem) 
{
  if(document.getElementById)
  {
    target = document.getElementById(elem);
    if(target.style.display == "none")
    {
      target.style.display = "";
    }
    else
    {
      target.style.display = "none";
    }
  }
}

function toggle_slide(elemId)
{
  if(document.getElementById)
  {
    target = document.getElementById(elemId);
    if(browser.isGecko && !browser.isKonqueror || browser.isSafari
        || browser.isOpera)
    {
        if(target.style.display == "none")
            new Effect.SlideDown(target);
        else
            new Effect.SlideUp(target);
    }
    else
    {
        if(target.style.display == "none")
            target.style.display = "block";
        else
            target.style.display = "none";
    }
  }
}

function clear_field(id)
{
  if(document.getElementById)
  {
    elem = document.getElementById(id);
    elem.value = '';
  }
}

/* This method catches when the enter key is pressed 
 * when on an input field and will cause to jump to the element
 * specified by the ID instead of submitting the form.
 */
function enter(id, event)
{
  if(event && event.keyCode == 13) 
  {
    if(document.getElementById)
    {
      document.getElementById(id).focus();
    }
    return false;
  }
  else
  {
    return true;
  }
}

/* Performs a DFS to find the first input element in the form
 * and sets the focus onto this element.
 */
function focus_form(id)
{
  if(document.getElementById && (form = document.getElementById(id)))
  {
    elements = form.getElementsByTagName('input');
    if(elements.length >= 1)
    {
      elements[0].focus();
    }
  }
}

/**
 * This function iterates through all the child <li> elements of the given
 * element and displays them one by one fading them in and out.
 */
FadeItems = Class.create();
FadeItems.prototype = (function() {}).extend({
    initialize: function(elem) 
    {
        this.p = elem;
        this.p.style.display = "none";
        this.i = 0;
        this.current = null;
        this.counter = 0;
        if(this.p)
        {
            this.c = this.p.getElementsByTagName('li');
            var i = 0;
            for(i = 0; i < this.c.length; i++)
            {
                Element.hide(this.c[i]);
            }
        }
        this.p.style.display = "block";
        this.fadeOut();
    },

    fadeOut: function() {
        if(this.counter == 0 && this.current != null)
        {
            new Effect.Fade(this.current);
            this.current = null;
            this.counter = 11;
            setTimeout(this.fadeOut.bind(this), 100);
        }
        else if(this.counter > 0)
        {            
            this.counter--;
            setTimeout(this.fadeOut.bind(this), 100);
        }
        else 
        {
            this.current = this.c[this.i];
            this.i++;
            if(this.i == this.c.length)
            {
                this.i = 0;
            }
            this.fadeIn();
        }
    },
     
    fadeIn: function() 
    {
        if(this.counter == 0 && this.current)
        {
            new Effect.Appear(this.current);
            this.counter = 30;
            setTimeout(this.fadeIn.bind(this), 100);
        }
        else if(this.counter > 0)
        {            
            this.counter--;
            if(this.counter == 0)
            {
                this.fadeOut();
            }
            else
            {
                setTimeout(this.fadeIn.bind(this), 100);
            }
        }
    }
});

// ----------------------------------------------
// StyleSwitcher functions written by Paul Sowden
// http://www.idontsmoke.co.uk/ss/
// - - - - - - - - - - - - - - - - - - - - - - -
// For the details, visit ALA:
// http://www.alistapart.com/stories/alternate/
// ----------------------------------------------

function setActiveStyleSheet(title, reset) 
{
    var i, a, main;
    for(i = 0; (a = document.getElementsByTagName("link")[i]); i++) 
    {
        if(a.getAttribute("rel").indexOf("style") != -1 
            && a.getAttribute("title")) 
        {
            a.disabled = true;
            if(a.getAttribute("title") == title)
                a.disabled = false;
        }
    }
}

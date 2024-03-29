/* tigerevents-functions.js
 *
 * This file contains TigerEvents specific JavaScript functions used
 * throughout the view.
 */

/* This is a quick tooltip hack, based on
 * http://www.webmatze.de/webdesign/javascript/tooltips.htm */
tooltip_obj = null;
document.onmousemove = updateTooltip;

function toggle_help(e, id)
{
    help_obj = document.getElementById(id);
    if(help_obj)
    {
        if(help_obj.style.display == "block")
        {
            help_obj.style.display = "none";
        }
        else
        {        
            x = (document.all) ? window.event.x + document.body.scrollLeft 
                               : e.pageX;
            y = (document.all) ? window.event.y + document.body.scrollTop
                               : e.pageY;
            width = help_obj.style.width;
            width = width.substring(0, width.length - 2);
            help_obj.style.display = "block";
            help_obj.style.left = eval("(x - " + width + ") + \"px\"");
            help_obj.style.top = (y + 20) + "px";
        }
    }
}

function updateTooltip(e)
{
    x = (document.all) ? window.event.x + document.body.scrollLeft 
                       : e.pageX;
    y = (document.all) ? window.event.y + document.body.scrollTop
                       : e.pageY;
    if(tooltip_obj)
    {
        tooltip_obj.style.left = (x) + "px";
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

function toolTipOn(e)
{
    tooltip_obj = e;
    tooltip_obj.style.display = "block";
}

function toolTipOff()
{
    tooltip_obj.style.display = "none";
    tooltip_obj = null;
}

function getSiblingByClass(e, c)
{
    var i;
    var n = e.parentNode.childNodes.length;
    for(i = 0; i < n; i++)
    {
        if(e.parentNode.childNodes[i].className == c)
            return e.parentNode.childNodes[i];
    }
    return 0;
}

function mail(b, a)
{
    window.location = 'mailto:' + a + '@' + b;
}

function show(elem)
{
    if(document.getElementById)
    {
        target = document.getElementById(elem);
        target.style.display = "";
    }
}

function hide(elem)
{
    if(document.getElementById)
    {
        target = document.getElementById(elem);
        target.style.display = "none";
    }
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

function toggle_fade(elemId)
{
  if(document.getElementById)
  {
    target = document.getElementById(elemId);
    if(browser.isGecko && !browser.isKonqueror || browser.isSafari
        || browser.isOpera)
    {
        if(target.style.display == "none")
        {
            Element.hide(elemId);
            new Effect.Appear(elemId, {duration: 0.3});
            // target.style.display = "block";
        }
        else
        {
            Element.show(elemId);
            new Effect.Fade(target, {duration: 0.3});
            // target.style.display = "none";
        }
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
Object.extend(FadeItems.prototype, {
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

function toggle_action_link(id, on, off)
{
    var elem;

    if(document.getElementById)
    {
        elem = document.getElementById(id)
    }
    else if(document.all)
    {
        elem = eval("document.all." + id)
    }
    else
        return false;

    if(elem.innerHTML == on)
    {
        elem.innerHTML = off;
    }
    else
    {
        elem.innerHTML = on;
    }
}

function quicklink(selObj, restore)
{
    if(selObj.options[selObj.selectedIndex].value) 
        eval("parent.location='" + selObj.options[selObj.selectedIndex].value + "'");
    if(restore)
        selObj.selectedIndex = 0;
}



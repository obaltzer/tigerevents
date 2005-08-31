/* tigerevents.js
 *
 * This file contains TigerEvents specific JavaScript functions used
 * throughout the view.
 */
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
    if(target.style.display == "none")
    {
      new Effect.SlideDown(target);
    }
    else
    {
      new Effect.SlideUp(target);
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

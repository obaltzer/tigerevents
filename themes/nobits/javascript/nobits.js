window.addEvent('domready', function(){
    var tooltips = new Tips($$('.tooltip'));
    
    
    var szNormal = 45, szSmall = 45, szFull = 120;
        
    var selectors = $$("ul.events");
    selectors.each(function(selector, i) {
      var events = selector.getElements("li");
      var fx = new Fx.Elements(events, {wait: false, duration: 200, transition: Fx.Transitions.Back.easeOut});
      events.each(function(e, i) {
        e.addEvent("mouseenter", function(event) {
          var o = {};
          o[i] = {height: [e.getStyle("height").toInt(), szFull]}
          events.each(function(other, j) {
            if(i != j) {
              var w = other.getStyle("height").toInt();
              if(w != szSmall) o[j] = {height: [w, szSmall]};
            }
          });
          fx.start(o);
        });
      });
    });
}); 

function sidebar_hide()
{   
    var sb = $('sidebar');
    sb.setStyle('width', '0');
    sb.setStyle('display', 'none');
    $('main').setStyle('margin-left', '0');
}

function sidebar_show()
{    
    var sb = $('sidebar');
    sb.setStyle('width', '200px');
    sb.setStyle('display', 'block');
    $('main').setStyle('margin-left', '200px');
}

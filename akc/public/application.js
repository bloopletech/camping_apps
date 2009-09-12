// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function $(ele)
{
   return document.getElementById(ele);
}

function pad(str)
{
   str = str + "";
   if(str.length == 0) return "00";
   if(str.length == 1) return "0" + str;
   if(str.length == 2) return str;
}

function doDates(ele)
{
   var ie = true;//!!(window.attachEvent && !window.opera);
   var nodes = ele.childNodes;
   if(nodes[ie ? 0 : 1].nodeName == "TBODY") nodes = nodes[ie ? 0 : 1].childNodes;

   for(i = 0; i < nodes.length; i++)
   {
      var tr = nodes.item(i);
      if(tr.nodeName != "TR") continue;

      var td = tr.lastChild;
      if(!ie) td = td.previousSibling;
      if(td.nodeName != "TD") continue;

      var when = new Date(parseInt(td.getAttribute("rel")));
      td.innerHTML = pad(when.getDate()) + "/" + pad(when.getMonth() + 1) + "/" + when.getFullYear() + " "
       + pad(when.getHours() > 12 ? when.getHours() - 12 : (when.getHours() == 0 ? 12 : when.getHours())) + ":" + pad(when.getMinutes()) + " "
        + (when.getHours() > 11 ? "PM" : "AM");
   }
}

var http = null;
var callback = null;

function loadURL(str, inCallback)
{
   callback = inCallback;
   http.open("get", str, true);
   http.onreadystatechange = function()
   {
      if(http.readyState == 4 && callback != null) callback(http.responseText);
   };
   http.send(null);
}

function addShout()
{
   loadURL("/add_shout?ajax=1&shout[username]=" + encodeURIComponent($("shout_username").value) + "&shout[text]="
    + encodeURIComponent($("shout_text").value) + "&shout[captcha]=" + encodeURIComponent($("shout_captcha").value), function()
   {
      $("shouts").innerHTML = http.responseText;
      if(http.responseText.indexOf("<!-- shoutbox -->") >= 0) location.href = "#shoutbox";
      else if(http.responseText.indexOf("<!-- shoutbox_form -->") >= 0) location.href = "#shoutbox_form";
      doDates($("shoutbox"));
   });
   return false;
}

function show(type)
{
   for(old_type in types) $(old_type).style.display = 'none';
   $(type).innerHTML = types[type];
   $(type).style.display = '';
}

function parseForDates(elements)
{
   for(var i = 0; i < elements.length; i++)
   {
      var ele = elements[i];
      if(ele.getAttribute("rel") != null)
      {
         var when = new Date(parseInt(ele.getAttribute("rel")));
         ele.innerHTML = pad(when.getDate()) + "/" + pad(when.getMonth() + 1) + "/" + when.getFullYear() + " "
          + pad(when.getHours() > 12 ? when.getHours() - 12 : (when.getHours() == 0 ? 12 : when.getHours())) + ":" + pad(when.getMinutes()) + " "
           + (when.getHours() > 11 ? "PM" : "AM");
      }
   }
}

// ondomloaded code by Dean Edwards/Matthias Miller/John Resig

function init()
{
   if (arguments.callee.done) return;
   arguments.callee.done = true;
   if (_timer) clearInterval(_timer);

   if($("utc"))
   {
      $("utc").style.display = "none";
      $("local").style.display = "block";
   }

   parseForDates(document.getElementsByTagName("td"));
   parseForDates(document.getElementsByTagName("span"));

   if($("shoutbox"))
   {
     doDates($("shoutbox"));

     for(old_type in types) $(old_type).style.display = 'none';
     $('manual').style.display = "none";
     $('choice').style.display = 'block';
   }

   try
   {
      http = new ActiveXObject("Microsoft.XMLHTTP");
   }
   catch(e)
   {
      try
      {
         http = new XMLHttpRequest();
      }
      catch(e)
      {
      }
   }
}

/* for Mozilla/Opera9 */
if (document.addEventListener) document.addEventListener("DOMContentLoaded", init, false);

/* for Internet Explorer */
/*@cc_on @*/
/*@if (@_win32)
  document.write("<script id=__ie_onload defer src=javascript:void(0)><\/script>");
  var script = document.getElementById("__ie_onload");
  script.onreadystatechange = function() {
    if (this.readyState == "complete") init();
  };
/*@end @*/

/* for Safari */
if (/WebKit/i.test(navigator.userAgent)) { // sniff
  var _timer = setInterval(function() {
    if (/loaded|complete/.test(document.readyState)) init();
  }, 10);
}

/* for other browsers */
window.onload = init;
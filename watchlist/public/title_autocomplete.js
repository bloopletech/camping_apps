function editItem(edit_link)
{
  
}

document.observe('dom:loaded', function()
{
  $('title').observe('keyup', function()
  {
    if($('title').readAttribute('last_good_value') != $('title').value)
    {
      $('title_id').value = '';
      $('medium_id').show();
    }
    else
    {
      $('title_id').value = $('title_id').readAttribute('last_good_id');
      $('medium_id').hide();
    }
  });
  
  $('title').writeAttribute('last_good_value', $('title').value);
  $('title_id').writeAttribute('last_good_id', $('title_id').value);

  $('consumed').observe('click', function()
  {
    if($('consumed').value == 'list')
    {
      $('consumed_advanced').show();
    }
    else
    {
      $('consumed_advanced').hide();
    }
  });

  if(!$('create_form'))
  {
    return;
  }

  $('submit').observe('click', function(event)
  {
    event.stop();

    new Ajax.Request('/watchlist/items/create', { parameters: $('create_form').serialize() + "&ajax=1", onSuccess: function(transport)
    {
      var res = eval("(" + transport.responseText + ")");
      if(res.error != undefined)
      {
        alert(res.error);
        return;
      }

      var tbody = $('table_body');
      var tr = tbody.insertRow(tbody.childNodes.length - 1);

      tr.insertCell(-1).innerHTML = "<a href='/watchlist/titles/" + res.title_id + "'>" + res.title + "</a>";
      tr.insertCell(-1).innerHTML = res.consumed;
      tr.insertCell(-1).innerHTML = res.when;
      last = tr.insertCell(-1);
      last.innerHTML = res.links;
      last.className = "last_r";
    }});
  });

  new Ajax.Autocompleter('title', 'title_autocomplete', '/watchlist/autocomplete/title', { method: 'get', minChars: 2, frequency: 1.0, afterUpdateElement: function(input_field, li)
  {
    $('title_id').value = li.id;
    $('title').writeAttribute('last_good_value', li.innerHTML);
    $('title_id').writeAttribute('last_good_id', li.id);
    $('medium_id').hide();
  } });
});
tinymce_options = {
    language : "en",
    mode: "specific_textareas",
    editor_selector: "tinymce",
    theme : "advanced",
    height: "500",
    plugins : "searchreplace,contextmenu,paste,style,advimage,table,media,advlink",
    theme_advanced_toolbar_location : "top",
    theme_advanced_toolbar_align : "left",
    theme_advanced_buttons1 : "bold,italic,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,link,unlink,image,media,code,codetag,|,formatselect",
    theme_advanced_buttons2 : "pasteword,cleanup,charmap,|,undo,redo,|,search,replace,|,tablecontrols",
    theme_advanced_buttons3 : "",

    // To set advanced styles, simply insert this pattern into the quotes below 
    //     NAME=CLASS_NAME;NAME=CLASS_NAME
    // using upper/lowercase names where appropriate
    theme_advanced_styles : "",
    table_cell_styles : "",
    table_row_styles : "",
    
    theme_advanced_statusbar_location : "bottom",
    theme_advanced_resizing: true,
    inline_styles : true,
    verify_html: true,
    paste_use_dialog : false,
    paste_auto_cleanup_on_paste : true,
    convert_fonts_to_spans: true,
    apply_source_formatting : true,
    paste_convert_headers_to_strong : false,
    paste_strip_class_attributes : "all",
    invalid_elements: "font",
    relative_urls: false,
    document_base_url: "/",
    content_css: "/content.css",
    setup: function(ed)
    {
      // Add Custom Code
      ed.addButton('codetag',
      {
        title: 'Wrap code tags around selected text',
        image: '/script_code.png',
        onclick: function()
        {
          ed.execCommand("mceInsertContent", false, '<pre><code>CODE GOES WHERE?</code></pre>');
        }
      });
    }
};

tinyMCE.init(tinymce_options);
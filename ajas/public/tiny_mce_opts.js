var tiny_mce_opts = {
    language : "en",
    mode : "textareas",
    theme : "advanced",
    content_css : "/stylesheets/content.css",
    height: "350",
    plugins : "preview,searchreplace,contextmenu,paste,style,table,advimage,xhtmlxtras",
    theme_advanced_toolbar_location : "top",
    theme_advanced_toolbar_align : "left",
    theme_advanced_buttons1 : "bold,italic,separator,justifyleft,justifycenter,justifyright,justifyfull,separator,bullist,numlist,outdent,indent,separator,sup,sub,hr,charmap,separator,forecolor",
    theme_advanced_buttons2 : "undo,redo,separator,cut,copy,paste,separator,link,unlink,image,separator,visualaid,removeformat,cleanup,code",
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
    debug: true
};
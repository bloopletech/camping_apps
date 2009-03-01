var tiny_mce_opts = {
    language : "en",
    mode : "textareas",
    theme : "advanced",
    content_css : "/stylesheets/content.css",
    height: "400",
    theme_advanced_toolbar_location : "top",
    theme_advanced_toolbar_align : "left",
		plugins : "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",
		theme_advanced_buttons1 : "save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,styleselect,formatselect,fontselect,fontsizeselect",
		theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
		theme_advanced_buttons3 : "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",
		theme_advanced_buttons4 : "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak",
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
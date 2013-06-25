$.extend($.expr[':'], {
    contents: function(elem, i, attr){
      return $(elem).contents().find( attr[3] );
    }
});
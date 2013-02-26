
$=require('component-jquery');
$.ajax('/', {
  dataType: 'text',
  async: false,
  success: function(data){
    $(data.match(/navbar-->(.+)<\!--navbar/)[1]).prependTo('body');
  }
});




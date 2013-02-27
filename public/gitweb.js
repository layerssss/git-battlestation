
$=require('component-jquery');
$.ajax('/peers/', {
  dataType: 'text',
  async: false,
  success: function(data){
    $(data.match(/navbar-->(.+)<\!--navbar/)[1]).prependTo('body');
  }
});
$('.list').each(function(i, e){
  var match = $(e).text().match(/^(.+)\/\.git$/);
  if(match){
    var project = match[1];
    $(e).closest('tr').children(':last-child').append(' | <a href="/projects/' + project + '/master/">compare</a>');
    $(e).closest('tr').children(':last-child').append(' | <a href="/projects/' + project + '/updateRemotes/?_method=post">update remotes</a>');
  }
})




  $(function() {
  $('[name="btn"]:radio').change( function() {
    if($('[id=a]').prop('checked')){
      $('.text').fadeOut();
      $('.danceTable').fadeIn();
    } else if ($('[id=b]').prop('checked')) {
      $('.text').fadeOut();
      $('.kako4sou').fadeIn();
    }
  });
});
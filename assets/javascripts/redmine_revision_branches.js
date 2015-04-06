$(function() {
  $('a.scm-branch-group').on('click', function() {
    $(this).parent().removeClass('scm-branch-hide');
  })
});
$(document).on('turbolinks:load', function(){
    $(".alert-notice").delay(2000).slideUp(500, function(){
          $(".alert").alert('close');
      });
    });


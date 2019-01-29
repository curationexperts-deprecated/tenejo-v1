var Tenejo = {
  'displayUploadedFile': function() {
    var fileInput = document.querySelector('#file-upload')
    var files = fileInput.files
    for (var i = 0; i < files.length; i++) {
      var file = files[i]
      document.querySelector('#file-upload-display').innerHTML = '<div class="row">\n      <div class="col-md-8">\n      <div class="alert alert-success">\n<p>You sucessfully uploaded this CSV: <b>' + file.name + '</b></p>\n      </div>\n      </div>\n      </div>'
    }
  }
}

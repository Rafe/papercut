# PAPERCUT!

    var papercut = require('papercut');

    papercut.configure('production', function(){
      papercut.set('storage', 'S3')
      papercut.set('S3_KEY', process.env.S3_KEY)
      papercut.set('S3_SECRET', process.env.S3_SECRET)
      papercut.set('bucket', 'papercut')
    });

    papercut.configure(function(){
      papercut.set('storage', 'file')
      papercut.set('directory', './images/uploads')
      papercut.set('url', '/images/uploads')
    });

    AvatarUploader = papercut.Schema(function(schema){
      schema.version({
        name: 'avatar',
        size: '200x200',
        process: 'crop'
      });

      schema.version({
        name: 'small',
        size: '50x50',
        process: 'crop'
      });
    });

    uploader = new AvatarUploader();

    uploader.process('image1.png', file.path, function(images){
      console.log(images.avatar); // 'http://s3.amazon.com/papercut/image1.png'
      console.log(images.small); // 'http://s3.amazon.com/papercut/image1-small.png'
    })

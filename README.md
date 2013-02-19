# PAPERCUT!

Papercut handle image processing, versioning and storage for you, in node.js.

## Features

+ environment configuration
+ node-imagemagick integration for image resize, crop and copy.
+ S3 image upload

## Install

In terminal:

    npm install papercut --save

## Usage

    var papercut = require('papercut');

    papercut.configure(function(){
      papercut.set('storage', 'file')
      papercut.set('directory', './images/uploads')
      papercut.set('url', '/images/uploads')
    });

    papercut.configure('production', function(){
      papercut.set('storage', 's3')
      papercut.set('S3_KEY', process.env.S3_KEY)
      papercut.set('S3_SECRET', process.env.S3_SECRET)
      papercut.set('bucket', 'papercut')
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

    uploader.process('image1', file.path, function(images){
      console.log(images.avatar); // '/images/uploads/image1-avatar.jpg'
      console.log(images.small); // '/images/uploads/image1-small.jpg'
    })

## Configuration

In papercut, you can set the image directory and default process by getter and setter:

    var papercut = require('papercut');

    //storage type, have file and s3
    papercut.set('storage', 'file');
    //directory for saving image
    papercut.set('directory', './images/uploads');
    //url path to the directory
    papercut.set('url', '/images/uploads');
    //set output images extension
    papercut.set('extension', 'jpg');

Also, you can set the environment dependent configuration, it detect the `process.env.NODE_ENV` param.  
you can call `export NODE_ENV=[environment]` to change environment.

    papercut.configure('production', function(){
      //set storage to s3 for production environment
      papercut.set('storage', 's3');
      //set s3 key from environment.
      papercut.set('S3_KEY', process.env.S3_KEY);
      papercut.set('S3_SECRET', process.env.S3_SECRET);
      //s3 bucket name
      papercut.set('bucket', 'papercut');
    });

## Schema and Version

After configuration, you can create an uploader to process images with multiple version by Schema

    var Uploader = papercut.Schema(function(schema){
      schema.version({
        name: 'thumbnail',
        size: '45x45',
        process: 'crop'
      });

      schema.version({
        name: 'large',
        size: '600x480',
        process: 'resize'
      });

      schema.version({
        name: 'origin',
        process: 'copy'
      });
    });

You can also set custom param according to version

    var Uploader = papercut.Schema(function(schema){
      schema.version({
        name: 'auto',
        size: '120x120',
        process: 'crop'
        custom: ['-auto-orient']
      });
    });

## Process

With uploader, you can pass the image identifier and image path to process images.  
Also with images url in different versions:

    var uploader = new Uploader();

    uploader.process('412341', '/tmp/13912304.jpg', function(err, images){
      console.log(images);
      // {
      //  thumbnail: '/images/upload/412341-thumbnail.jpg',
      //  large: '/images/upload/412341-large.jpg',
      //  origin: '/images/upload/412341-origin.jpg'
      // }
    });

##Express

Check out the [express example](https://github.com/Rafe/papercut/blob/master/examples/express.coffee) in project for how to use it in express framework.

## Todos
+ Process image from previous one to improve processing speed.
+ Custom gravity
+ Api improvement

#### Licence : MIT

#### Author : [Jimmy Chao](http://neethack.com) (daizenga@gmail.com)

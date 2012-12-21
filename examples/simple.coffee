papercut = require('../')

papercut.configure ->
  papercut.set('storage', 'file')
  papercut.set('directory', './images/output')
  papercut.set('url', '/images/output')

papercut.configure 'production', ->
  papercut.set('storage', 's3')
  papercut.set('bucket', 'test')
  papercut.set('S3_KEY', process.env.S3_KEY)
  papercut.set('S3_SECRET', process.env.S3_SECRET)

Uploader = papercut.Schema (schema)->
  @version
    name: 'test'
    size: '640x480'
    process: 'crop'

  @version
    name: 'large'
    size: '200x200'
    process: 'resize'

  @version
    name: 'origin'
    process: 'copy'

uploader = new Uploader()

uploader.process 'test', './images/sample.jpg', (err, images)->
  console.log images.images

papercut = require('../')
path = require('path')

papercut.configure ->
  papercut.set('storage', 'file')
  papercut.set('directory', path.join(__dirname, '/../images/output'))
  papercut.set('url', '/output')
  papercut.set('process', 'crop')

papercut.configure 'production', ->
  papercut.set('storage', 's3')
  papercut.set('bucket', 'papercut')
  papercut.set('S3_KEY', process.env.S3_KEY)
  papercut.set('S3_SECRET', process.env.S3_SECRET)

AvatarUploader = papercut.Schema (schema)->
  @version
    name: 'thumbnail'
    size: '45x45'

  @version
    name: 'avatar'
    size: '200x200'

express = require('express')
app = express()

app.use express.static( path.join(__dirname, '/../images/'))
app.use express.bodyParser()

app.get '/', (req, res)->
  res.send 200, """
    <html>
      <head>
        <title>Papercut Example</title>
      </head>
      <body>
        <h1> Papercut! </h1>
        <form action='/avatar' method='post' enctype="multipart/form-data">
          <input type='file' name='avatar'/>
          <button>Upload</button>
        </form>
      </body>
    </html>
  """

imageId = 0

app.post '/avatar', (req, res)->
  uploader = new AvatarUploader()

  uploader.process "#{imageId++}", req.files.avatar.path, (err, images)->
    res.send 200, """
      <html>
        <head>
          <title>Papercut Example: Result</title>
          <body>
            <h1> Papercut! </h1>
            <img src='#{images.thumbnail}'/>
            <img src='#{images.avatar}'/>
          </body>
        </head>
      </html>
    """

console.log 'express listening port 3000...'
app.listen 3000

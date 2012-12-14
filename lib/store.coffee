fs = require('fs')
knox = require('knox')

exports.FileStore = class FileStore
  constructor: (@config)->
    @result = {}

  getDstPath: (name, version)->
    "#{@config.directory}/#{name}-#{version.name}.#{@config.extension}"

  getUrlPath: (name, version)->
    "#{@config.url or ''}/#{name}-#{version.name}.#{@config.extension}"

  save: (name, version, stdout, stderr, callback)=>
    @result[version.name] = @getUrlPath(name, version)
    fs.writeFile @getDstPath(name, version), stdout, 'binary', callback

exports.S3Store = class S3Store
  constructor: (@config)->
    @result = {}
    @awsUrl = "https://s3.amazonaws.com"
    @client = knox.createClient
      key: config.S3_KEY
      secret: config.S3_SECRET
      bucket: config.bucket
    @headers =
      'Content-Type': "image/#{@config.extention}"
      'x-amz-acl': 'public-read'

  getDstPath: (name, version)->
    "#{name}-#{version.name}.#{@config.extension}"

  save: (name, version, stdout, stderr, callback)=>
    buffer = new Buffer(stdout, 'binary')
    dstPath = @getDstPath name, version
    @headers['Content-Length'] = buffer.length
    @client.putBuffer buffer, dstPath, @headers, (err, res)=>
      @result[version.name] = "#{@awsUrl}/#{@config.bucket}/#{dstPath}"
      callback()

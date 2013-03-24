fs = require('fs')
knox = require('knox')
path = require('path')

###
Save file to directory and return url path according to your
route setting
###

exports.FileStore = class FileStore
  constructor: (@config, @result = {})->

  ###
  Return local path to save file

  @param {String} name
  @param {Object} version

  @api private
  ###
  getDstPath: (name, version)->
    path.join @config.directory, "#{name}-#{version.name}.#{@config.extension}"

  ###
  Return url path to image, according to your url setting

  @param {String} name
  @param {Object} version

  @api private
  ###
  getUrlPath: (name, version)->
    "#{@config.url or ''}/#{name}-#{version.name}.#{@config.extension}"

  ###
  Save image to directory and return all version url path to callback

  @param {String} name
  @param {Object} version
  @param {Object} stdout stream
  @param {Object} stderr stream
  @param {Function} callback

  @api public
  ###
  save: (name, version, stdout, stderr, callback)=>
    return callback(new Error(stderr)) if stderr? and stderr.length isnt 0

    @result[version.name] = @getUrlPath(name, version)

    fs.writeFile @getDstPath(name, version), stdout, 'binary', (err, file)=>
      callback(err, @result[version.name])

###
Upload file to Amazon S3 and return the url of file
Using knox module to upload
###

exports.S3Store = class S3Store
  constructor: (@config)->
    @result = {}
    @awsUrl = @config.awsUrl or "https://s3.amazonaws.com"
    @client = knox.createClient
      key: config.S3_KEY
      secret: config.S3_SECRET
      bucket: config.bucket
    @headers =
      'Content-Type': "image/#{@config.extension}"
      'x-amz-acl': 'public-read'

  ###
  Get relative file path on S3

  @param {String} name
  @param {Object} version

  @api private
  ###
  getDstPath: (name, version)->
    "#{name}-#{version.name}.#{@config.extension}"

  ###
  Get url path of file on S3

  @param {String} name
  @param {Object} version

  @api private
  ###
  getUrlPath: (name, version)->
    "#{@awsUrl}/#{@config.bucket}/#{name}-#{version.name}.#{@config.extension}"

  ###
  Upload file to S3 and return url path

  @param {String} name
  @param {Object} version
  @param {Object} stdout stream
  @param {Object} stderr stream
  @param {Function} callback

  @api public
  ###
  save: (name, version, stdout, stderr, callback)=>
    return callback(new Error(stderr)) if stderr? and stderr.length isnt 0

    buffer = new Buffer(stdout, 'binary')
    dstPath = @getDstPath name, version

    @headers['Content-Length'] = buffer.length
    @client.putBuffer buffer, dstPath, @headers, (err, res)=>
      @result[version.name] = @getUrlPath(name, version)
      callback(err, @result[version.name])

###
Test store for testing
###
exports.TestStore = class TestStore
  constructor: (@config)->
    @result = {}

  getUrlPath: (name, version)->
    "#{name}-#{version.name}.#{@config.extension}"

  getDstPath: (name, version)->
    "#{name}-#{version.name}.#{@config.extension}"

  save: (name, version, stdout, stderr, callback)=>
    @result[version.name] = @getUrlPath(name, version)
    callback(null, @result[version.name])

fs = require('fs')
im = require('imagemagick')

module.exports = class Processor
  constructor: (@config)->

  getSize: (size)->
    s = size.split('x')
    width: s[0], height: s[1]

  crop: (name, path, version, callback)->
    size = @getSize(version.size)
    params =
      srcPath: path
      width: size.width
      height: size.height
      format: @config.extension
      quality: @config.quality

    im.crop params, callback

  resize: (name, path, version, callback)->
    size = @getSize(version.size)
    params =
      srcPath: path
      width: size.width
      height: size.height
      format: @config.extension
      quality: @config.quality

    im.resize params, callback

  copy: (name, path, version, callback)->
    fs.readFile path, 'binary', callback

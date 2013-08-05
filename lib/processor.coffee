fs = require('fs')
im = require('imagemagick')

###
Process call node-imagemagick module to process images
and return file stream to callback
###

module.exports = class Processor
  im: im

  constructor: (@config)->

  getSize: (size)->
    s = size.split('x')
    width: s[0], height: s[1]

  ###
  Resize and crop image using node-imagemagic's crop method

  @param {String} name
  @param {String} path
  @param {Object} version
  @param {Function} callback

  @api public
  ###
  crop: (name, path, version, callback)->
    @process('crop', name, path, version, callback)

  ###
  Resize image

  @param {String} name
  @param {String} path
  @param {Object} version
  @param {Function} callback

  @api public
  ###
  resize: (name, path, version, callback)->
    @process('resize', name, path, version, callback)

  ###
  Copy image

  @param {String} name
  @param {String} path
  @param {Object} version
  @param {Function} callback

  @api public
  ###
  copy: (name, path, version, callback)->
    if name.indexOf @config.extension isnt -1
      fs.readFile path, 'binary', callback
    else
      callback(new Error("file extension is not #{@config.extension}"))

  ###
  Process image with methods,
  build params and call node-imagemagick's method

  @param {String} method
  @param {String} name
  @param {String} path
  @param {Object} version
  @param {Function} callback

  @api private
  ###
  process: (method, name, path, version, callback)->
    size = @getSize(version.size)
    gmi = @gm(path);
    output = name + "." + (version.extension or @config.extension)
    if name is "resize"
      gmi.resize size.width, size.height
    if name is "crop"
      gmi.crop size.width, size.height, 0, 0
    gmi.quality version.quality or @config.quality
    gmi.write output, callback

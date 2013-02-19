knox = require('knox')
async = require('async')
{FileStore, S3Store, TestStore } = require('./store')
Processor = require('./processor')

config = {
  storage: 'file'
  extension: 'jpg'
  process: 'resize'
  directory: '.'
  quality: 1,
  custom: []
}

module.exports = papercut =
  ###
  Execute block according current environment

  Example:

    papercut.configure 'development', ->
      papercut.configure ->
        papercut.set('storage', 'file')
        papercut.set('directory', './images/output')
        papercut.set('url', '/images/output')

    papercut.configure 'production', ->
      papercut.set('storage', 's3')
      papercut.set('bucket', 'test')
      papercut.set('S3_KEY', process.env.S3_KEY)
      papercut.set('S3_SECRET', process.env.S3_SECRET)

  @param {String} env
  @param {Function} block

  @api public
  ###

  configure: (env, block)->
    args = [].slice.call(arguments)
    block = args.pop()
    if not args.length
      block()
    else if env is process.env.NODE_ENV
      block()

  ###
  Get config value

  @param {String} name

  @api public
  ###

  get: (name)->
    config[name]

  ###
  Set value to config

  @param {String} name
  @param {Object} value

  @api public
  ###

  set: (name, value)->
    config[name] = value

  ###
  Return Upload class with customized versions and config

  Example:

    Uploader = papercut.Schema ->
      @version
        name: 'large'
        size: '600x400'

      @version
        name: 'thumbnail'
        size: '150x100'

    uploader = new Uploader()

  @param {Function} initializer

  @api public
  ###

  Schema: (initializer)->
    class Uploader
      constructor: ->
        @versions = []
        @config = config
        @processor = new Processor(@config)
        initializer.call(@, @) if initializer?

        if @config.storage is 'file'
          @store = new FileStore(@config)
        else if @config.storage is 's3'
          @store = new S3Store(@config)
        else if @config.storage is 'test'
          @store = new TestStore(@config)
        else
          throw new Error('No storage type')

      ###
      Set image name, process method and size

      Example:
        Uploader = papercut.Schema ->
          @version
            name: 'large'
            size: '600x400'
            process: 'resize'

      @param {Ojbect} version

      @api public
      ###

      version: (version)->
        @versions.push version

      ###
      Process and save image according versions and storage

      Example:

        uploader.process '2341230', '/tmp/image.jpg', (err, result)->
          console.log result
          # {
          #   large: '/images/2341230-large.jpg'
          #   thumbnail: '/images/2341230-thumbnail.jpg'
          # }

      @param {String} name
      @param {String} path
      @param {Function} callback

      @api public
      ###

      process: (name, path, callback)->
        errors = []
        async.forEach @versions, (version, done)=>
          method = version.process or @config.process
          @processor[method] name, path, version, (err, stdout, stderr)=>
            return done(err) if err?
            @store.save(name, version, stdout, stderr, done)
        , (err)=>
          callback(err, @store.result)

knox = require('knox')
async = require('async')

{FileStore, S3Store} = require('./store')
Processor = require('./processor')

config = {
  storage: 'file'
  extension: 'jpg'
  process: 'resize'
  directory: './'
  quality: 1
}

module.exports = papercut =
  configure: (env, block)->
    args = [].slice.call(arguments)
    block = args.pop()
    if not args.length
      block()
    else if env is process.env.NODE_ENV
      block()

  get: (name)->
    config[name]

  set: (name, value)->
    config[name] = value

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
        else
          throw new Error('No storage type')

      version: (version)->
        @versions.push version

      process: (name, path, callback)->
        errors = []
        async.forEach @versions, (version, done)=>
          @processor[version.process || @config.process] name, path, version, (err, stdout, stderr)=>
            return done(err) if err?
            @store.save(name, version, stdout, stderr, done)
        , (err)=>
          callback(err, @store.result)

fs = require('fs')

describe 'papercut', ->
  papercut = ''

  beforeEach ->
    papercut = require('../index')

  it 'can set/get config', ->
    papercut.set 'name', 'John'
    papercut.get('name').should.eql 'John'

  it 'have default config', ->
    papercut.get('storage').should.eql 'file'
    papercut.get('extension').should.eql 'jpg'
    papercut.get('process').should.eql 'resize'

  describe '.configure', ->
    it 'execute in all env', ->
      papercut.configure ->
        papercut.set 'flag', true
      papercut.get('flag').should.be.true

    it 'execute in specific env', ->
      process.env.NODE_ENV = 'test'
      papercut.configure 'test', ->
        papercut.set 'flag', true
      papercut.get('flag').should.be.true

    afterEach ->
      process.env.NODE_ENV = undefined

  describe 'Schema', ->
    it 'run initialize function', (done)->
      Uploader = papercut.Schema (schema)->
        schema.should.be.instanceof(Uploader)
        @should.be.instanceof(Uploader)
        done()
      uploader = new Uploader()
      uploader.should.be.instanceof(Uploader)

    it 'store configs', ->
      papercut.set('flag', on)
      papercut.set('store', 's3')
      Uploader = papercut.Schema()
      uploader = new Uploader()
      uploader.config.flag.should.be.ok
      uploader.config.store.should.eql 's3'

    it 'store versions', ->
      Uploader = papercut.Schema ->
        @version
          name: 'test'
          size: '250x250'
          process: 'crop'
        @version
          name: 'test2'
          size: '16x16'
        @version
          name: ''
          process: 'copy'
      uploader = new Uploader()
      uploader.versions.length.should.eql 3
      version = uploader.versions[0]
      version.name.should.eql 'test'
      version.size.should.eql '250x250'

    describe 'process', ->

      uploader = ''
      beforeEach ->
        papercut.set('directory', './images/output')
        Uploader = papercut.Schema ->
          @version
            name: 'test'
            size: '250x250'
            process: 'crop'
        uploader = new Uploader()

      it 'store image to directory', (done)->
        uploader.process 'test', './images/sample.jpg', (err, images)->
          fs.existsSync('./images/output/test-test.jpg').should.be.true
          done()

      it 'should handle error', (done)->
        uploader.process 'error', './images/error.jpg', (err, images)->
          fs.existsSync('./images/output/error-test.jpg').should.be.false
          err.should.be.ok
          done()

      after ->
        [
          './images/output/error-test.jpg'
          './images/output/test-test.jpg'
        ].forEach (image)->
          fs.unlinkSync(image) if fs.existsSync(image)

fs = require('fs')

sample = './images/sample.jpg'
errorSample = './images/error.jpg'

{ S3Store, FileStore, TestStore } = require('../lib/store')

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
    it 'executed in all env', ->
      papercut.configure ->
        papercut.set 'flag', true
      papercut.get('flag').should.be.true

    it 'executed in specific env', ->
      process.env.NODE_ENV = 'test'
      papercut.configure 'test', ->
        papercut.set 'flag', true
      papercut.get('flag').should.be.true


    describe 'storage', ->
      it "initialize FileStore", ->
        papercut.set 'storage', 'file'
        Uploader = papercut.Schema ->
        uploader = new Uploader()
        uploader.store.should.be.an.instanceof FileStore

      it "initialize S3Store", ->
        papercut.set 'storage', 's3'
        papercut.set 'S3_KEY', 'test'
        papercut.set 'S3_SECRET', 'test'
        papercut.set 'bucket', 'test'

        Uploader = papercut.Schema ->
        uploader = new Uploader()
        uploader.store.should.be.an.instanceof S3Store

      it "initialize TestStore", ->
        papercut.set 'storage', 'test'
        Uploader = papercut.Schema ->
        uploader = new Uploader()
        uploader.store.should.be.an.instanceof TestStore

    afterEach ->
      process.env.NODE_ENV = undefined

  describe 'Schema', ->
    it 'run initialize function', (done)->
      Uploader = papercut.Schema (schema)->
        schema.should.be.instanceof(Uploader)
        this.should.be.instanceof(Uploader)
        done()
      uploader = new Uploader()

    it 'store configs', ->
      papercut.set('flag', on)
      papercut.set('store', 's3')
      Uploader = papercut.Schema()
      uploader = new Uploader()
      uploader.config.flag.should.be.ok
      uploader.config.store.should.eql 's3'
      uploader.store

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
        papercut.set('url', '/images')
        papercut.set('storage', 'file')
        Uploader = papercut.Schema ->
          @version
            name: 'cropped'
            size: '250x250'
            process: 'crop'
          @version
            name: 'origin'
            process: 'copy'
          @version
            name: 'resized'
            size: '250x250'
            process: 'resize'
        uploader = new Uploader()

      it 'process and store image to directory', (done)->
        uploader.process 'test', sample, (err, images)->
          fs.existsSync('./images/output/test-cropped.jpg').should.be.true
          fs.existsSync('./images/output/test-resized.jpg').should.be.true
          fs.existsSync('./images/output/test-origin.jpg').should.be.true
          images.origin.should.eql '/images/test-origin.jpg'
          images.cropped.should.eql '/images/test-cropped.jpg'
          images.resized.should.eql '/images/test-resized.jpg'
          done()

      it 'should handle error', (done)->
        uploader.process 'error', errorSample, (err, images)->
          fs.existsSync('./images/output/error-cropped.jpg').should.be.false
          fs.existsSync('./images/output/error-resized.jpg').should.be.false
          # copy will still copy file
          fs.existsSync('./images/output/error-origin.jpg').should.be.true
          err.should.be.ok
          done()

      #should in processor_test
      it 'should throw no file error', (done)->
        uploader.process 'nofile', './images/nofile.jpg', (err, images)->
          err.should.be.ok
          done()

      after cleanFiles

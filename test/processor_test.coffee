Processor = require('../lib/processor')

describe "Processor", ->
  processor = ''
  version = ''

  beforeEach ->
    processor = new Processor
      extension: 'jpg'
      quality: 1
    version =
      name: 'test'
      size: '320x160'

  it "should parse size", ->
    size = processor.getSize(version.size)
    size.width.should.eql '320'
    size.height.should.eql '160'

  describe 'process', ->

    it "should crop image", (done)->
      processor.crop 'test', './images/sample.jpg', version, (err, stdout, stderr)->
        err?.should.be.false
        (typeof stdout).should.eql 'string'
        done()

    it "should resize image", (done)->
      processor.resize 'test', './images/sample.jpg', version, (err, stdout, stderr)->
        err?.should.be.false
        (typeof stdout).should.eql 'string'
        done()

    it "should copy image", (done)->
      processor.copy 'test', './images/sample.jpg', version, (err, file)->
        err?.should.be.false
        file?.should.be.ok
        done()

    it "should handle error", (done)->
      processor.crop 'test', './images/error.jpg', version, (err, stdout, stderr)->
        err?.should.be.ok
        err.message.should.match /Error/
        done()

fs = require('fs')
path = require('path')
{ FileStore, S3Store , TestStore } = require('../lib/store')

describe 'FileStore', ->
  store = ''
  version = ''

  beforeEach ->
    store = new FileStore
      extension: 'jpg'
      directory: dir
      url: '/images'
    version =
      name: 'test'
      extension: 'jpg'

  it 'should return dstPath', ->
    store.getDstPath('test', version)
      .should.eql path.join(dir, '/test-test.jpg')

  it 'should return urlPath', ->
    store.getUrlPath('test', version)
      .should.eql '/images/test-test.jpg'

  it 'should auto adjust different url', ->
    store.config.directory = './images/output/'
    store.getDstPath('test', version)
      .should.eql path.join(dir, '/test-test.jpg')

  describe 'save', ->
    it 'should save file', (done)->
      stream = fs.createReadStream('./images/sample.jpg')
      store.save 'test', version, stream, null, (err, url)->
        fs.existsSync(path.join(dir, '/test-test.jpg')).should.be.ok
        url.should.eql '/images/test-test.jpg'
        store.result[version.name].should.eql '/images/test-test.jpg'
        done()

    it 'should handle error', (done)->
      emptyStream = ''
      store.save 'test', version, emptyStream, 'ENOENT', (err, url)->
        err.message.should.eql 'ENOENT'
        done()

    after cleanFiles

  describe 'delete', ->
    before (done)->
      fs.open(path.join(dir, '/test-test.jpg'), 'w', done)

    it 'should delete file', (done)->
      store.delete 'test', version, (err, url)->
        fs.existsSync(path.join(dir, '/test-test.jpg')).should.not.be.ok
        url.should.eql '/images/test-test.jpg'
        done()

    it 'should handle error', (done)->
      store.delete 'no-file', version, (err, url)->
        err.message.should.eql 'ENOENT, unlink \'images/output/no-file-test.jpg\''
        done()

    after cleanFiles

describe "S3Store", ->
  store = ''
  version = ''

  beforeEach ->
    store = new S3Store
      extension: 'jpg'
      bucket: 'test'
      S3_KEY: 'test'
      S3_SECRET: 'test'
    version =
      name: 'test'
      extension: 'jpg'
    store.client =
      putBuffer: (buffer, dstPath, headers, callback)->
        callback()
      deleteFile: (dstPath, callback)->
        callback()

  it 'should return dstPath', ->
    store.getDstPath('test', version)
      .should.eql 'test-test.jpg'

  it 'should return urlPath with s3 url', ->
    store.getUrlPath('test', version)
      .should.eql store.awsUrl + '/test/test-test.jpg'

  it 'should upload file to s3', (done)->
    store.save 'test', version, 'test', null, (err, url)->
      url.should.eql store.awsUrl + '/test/test-test.jpg'
      done()

  it 'should handle upload process error', (done)->
    store.save 'test', version, 'test', 'Error', (err, url)->
      err.message.should.eql 'Error'
      done()

  it 'should handle upload error', (done)->
    store.client =
      putBuffer: (buffer, dstPath, headers, callback)->
        callback(new Error('Upload Error'))

    store.save 'test', version, 'test', null, (err, url)->
      err.message.should.eql 'Upload Error'
      done()

  it 'should remove file from s3', (done)->
    store.delete 'test', version, (err, url)->
      url.should.eql store.awsUrl + '/test/test-test.jpg'
      done()

  it 'should handle remove error', (done)->
    store.client =
      deleteFile: (dstPath, callback)->
        callback(new Error('Upload Error'))

    store.delete 'test', version, (err, url)->
      err.message.should.eql 'Upload Error'
      done()

describe "TestStore", ->
  it "do nothing on storing images", ->
    version = 
      name: 'test'
      extension: 'jpg'
    store = new TestStore
      extension: 'jpg'
    store.save 'test', version, 'test', null, (err, url)->
      url.should.eql 'test-test.jpg'
    store.delete 'test', version, (err, url)->
      url.should.eql 'test-test.jpg'

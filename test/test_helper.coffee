fs = require('fs')
path = require('path')

global.dir = './images/output'

global.cleanFiles = (done)->
  fs.readdir dir, (err, files)->
    files?.forEach (file)->
      image = path.join(dir, file)
      fs.unlinkSync(image) if fs.existsSync(image)
    done()

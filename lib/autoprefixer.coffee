postcss  = require('postcss')

Browsers = require('./browsers')
Prefixes = require('./prefixes')

inspectCache = null

# Parse CSS and add prefixed properties and values by Can I Use database
# for actual browsers.
#
#   var prefixed = autoprefixer('> 1%', 'ie 8').compile(css);
#
# If you want to combine Autoprefixer with another PostCSS processor:
#
#   postcss.use(autoprefixer('last 1 version').postcss).
#           use(compressor).
#           process(css);
autoprefixer = (reqs...) ->
  if reqs.length == 1 and reqs[0] instanceof Array
    reqs = reqs[0]
  else if reqs.length == 0 or (reqs.length == 1 and not reqs[0]?)
    reqs = undefined

  reqs = autoprefixer.default unless reqs?

  browsers = new Browsers(autoprefixer.data.browsers, reqs)
  prefixes = new Prefixes(autoprefixer.data.prefixes, browsers)
  new Autoprefixer(prefixes, autoprefixer.data)

autoprefixer.data =
  browsers: require('../data/browsers')
  prefixes: require('../data/prefixes')

class Autoprefixer
  constructor: (@prefixes, @data) ->
    @browsers = @prefixes.browsers.selected

  # Parse CSS and add prefixed properties for selected browsers
  compile: (str) ->
    @processor().process(str)

  # Return PostCSS processor, which will add necessary prefixes
  postcss: (css) =>
    @prefixes.processor.add(css)
    @prefixes.processor.remove(css)

  # Return string, what browsers selected and whar prefixes will be added
  inspect: ->
    inspectCache ||= require('./inspect')
    inspectCache(@prefixes)

  # Cache PostCSS processor
  processor: ->
    @processorCache ||= postcss(@postcss)

# Autoprefixer default browsers
autoprefixer.default = ['> 1%', 'last 2 versions', 'ff 17', 'opera 12.1']

# Lazy load for Autoprefixer with default browsers
autoprefixer.loadDefault = ->
  @defaultCache ||= autoprefixer(@default)

# Compile with default Autoprefixer
autoprefixer.compile = (str) ->
  @loadDefault().compile(str)

# PostCSS with default Autoprefixer
autoprefixer.postcss = (css) ->
  @loadDefault().postcss(css)

# Inspect with default Autoprefixer
autoprefixer.inspect = ->
  @loadDefault().inspect()

module.exports = autoprefixer

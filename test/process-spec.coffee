suite 'Process Spec', ->

  teardown fs.reset

  test 'falsey `node` option disables process emulation', ->
    fixtures '/a.js': 'module.exports = typeof process'
    eq 'object', bundleEvalSync 'a.js'
    eq 'undefined', bundleEvalSync 'a.js', node: no

  test 'process.title is "browser"', ->
    fixtures '/a.js': 'module.exports = process.title'
    eq 'browser', bundleEvalSync 'a.js'

  test 'process.version is the version of node that did the bundling', ->
    fixtures '/a.js': 'module.exports = process.version'
    eq process.version, bundleEvalSync 'a.js'

  test 'process.browser is truthy', ->
    fixtures '/a.js': 'module.exports = process.browser'
    ok bundleEvalSync 'a.js'

  test 'process.cwd defaults to "/"', ->
    fixtures '/a.js': 'module.exports = process.cwd()'
    eq '/', bundleEvalSync 'a.js'

  test 'process.chdir changes process.cwd result', ->
    fixtures '/a.js': 'process.chdir("/dir"); module.exports = process.cwd()'
    eq '/dir', bundleEvalSync 'a.js'

  test 'process.argv is an empty array', ->
    fixtures '/a.js': 'module.exports = process.argv'
    arrayEq [], bundleEvalSync 'a.js'

  test 'process.env is an empty object', ->
    fixtures '/a.js': 'module.exports = Object.keys(process.env)'
    arrayEq [], bundleEvalSync 'a.js'

  test 'process.nextTick should use setImmediate if available', ->
    fixtures '/a.js': 'module.exports = process.nextTick'
    indicator = ->
    eq indicator, bundleEvalSync 'a.js', null, setImmediate: indicator

  test 'process.nextTick should use setTimeout if setImmediate is not available', ->
    fixtures '/a.js': 'process.nextTick(setTimeout)'
    called = no
    indicator = (fn, delay) ->
      called = yes
      eq indicator, fn
      eq 0, delay
    bundleEvalSync 'a.js', null, setImmediate: null, setTimeout: indicator
    ok called

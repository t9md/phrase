# Phrase: adviseMethod with modifying arguments and etc..
# ---------------------------------
adviseMethod = (obj, method, options) ->
  before = typeof options.before is 'function'
  after =  typeof options.after is 'function'
  base = obj[method].bind(obj)
  if before and after
    (params...) ->
      res = options.before.call(obj, params...)
      if res
        return res.response if res.stop?
        params = res.params if res.params?
      base params...
      options.after.call(obj, params...)
  else if before
    (params...) ->
      res = options.before.call(obj, params...)
      if res
        return res.response if res.stop?
        params = res.params if res.params?
      base params...
  else if after
    (params...) ->
      base params...
      options.after.call(obj, params...)
  else
    throw "advise: must not happen"

class Test
  constructor: (@name) ->
  greet: (msg) ->
    console.log "#{msg}: #{@name}"

t = new Test 't9md'

capitalizeGreeting = adviseMethod t, 'greet',
  before: (params...) ->
    params = params.map (e) -> e[0].toUpperCase() + e[1..]
    console.log "audit before: #{params}"
    {params}
  after: (params...) ->
    console.log "audit after: #{params}"

stopGreeting = adviseMethod t, 'greet',
  before: (params...) ->
    if params[0] is 'wanna stop'
      return {stop: true, response: 'stopped'}
    params = params.map (e) -> e[0].toUpperCase() + e[1..]
    console.log "audit before: #{params}"
    {params}

console.log "- Pre advise"
t.greet 'hello'
console.log "- Capitalize greeting"
t.greet= capitalizeGreeting
t.greet 'hello'
console.log "- Conditional stopping"
t.greet= stopGreeting
console.log "-- normal argument"
t.greet 'hello'
console.log "-- stopping"
returnValue = t.greet 'wanna stop'
console.log returnValue

""" Output:
- Pre advise
hello: t9md
- Capitalize greeting
audit before: Hello
Hello: t9md
audit after: Hello
- Conditional stopping
-- normal argument
audit before: Hello
Hello: t9md
-- stopping
stopped
"""

# Phrase: advise function
# ---------------------------------
# short version
advise = (base, options) ->
  funcs = []
  funcs.push options.before if (typeof options.before is 'function')
  funcs.push base
  funcs.push options.after if (typeof options.after is 'function')
  (params...) ->
    for func in funcs
      func params...

# rather long but efficient
advise = (base, options) ->
  before = typeof options.before is 'function'
  after =  typeof options.after is 'function'
  if before and after
    (params...) ->
      options.before params...
      base params...
      options.after params...
  else if before
    (params...) ->
      options.before params...
      base params...
  else if after
    (params...) ->
      base params...
      options.after params...
  else
    throw "advise: must not happen"

greet = (name, msg) ->
  console.log "#{msg}:#{name}"

greet = advise greet,
  before: (params...) ->
    console.log "audit before: #{params}"
  after: (params...) ->
    console.log "audit after: #{params}"

greet "t9md", "hello"
console.log "--"
greet "t9md", "bye"

""" Output:
audit before: t9md,hello
hello:t9md
audit after: t9md,hello
--
audit before: t9md,bye
bye:t9md
audit after: t9md,bye
"""

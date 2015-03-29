query = require "../index"

describe "wolfram alpha (these are just to test the bindings, not wolfram itself)", () ->

  it "search for star trek details in wolfram alpha", () ->
    query "star trek", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.wolfram"

      expect(r.response.msg).toMatch /star trek/gi
      expect(r.response.msg).toMatch /(3[ \:|\.]+seasons|seasons[ \:|\.]+3)/gi

  it "retreiving trig values from wolfram alpha", () ->
    query "sine of 90 degrees", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.wolfram"

      expect(r.response.msg).toMatch /(1|one)/gi

  it "defining words from wolfram alpha", () ->
    query "define quirky", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.wolfram"

      expect(r.response.msg).toContain "unconventional"

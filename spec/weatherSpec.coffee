query = require "../index"

describe "general weather operations", () ->

  it "should return the current weather conditions for the default location and current time", () ->
    query "weather", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.weather"

  it "should return the current weather conditions for a specific location", () ->
    query "weather in syracuse", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.weather"

  it "should return the current weather conditions for a specific time", () ->
    query "weather at 5:00pm", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.weather"

  it "should return the current weather conditions for a specific location and specific time", () ->
    query "weather in syracuse at 6:00am tomorrow", session: [], (r1) ->
      query "weather at 6:00am tomorrow in syracuse", session: [], (r2) ->

        # both requests should be fully defined
        expect(r1.response.msg).toBeDefined()
        expect(r1.datapoints.by).toBeDefined()
        expect(r1.datapoints.by).toEqual "nlp.weather"

        expect(r2.response.msg).toBeDefined()
        expect(r2.datapoints.by).toBeDefined()
        expect(r2.datapoints.by).toEqual "nlp.weather"

        # and should be equal
        expect(r1.response.msg).toEqual r2.response.msg

describe "temperature weather operations", () ->

  it "should return the current temperature for the default location and default time", () ->
    query "temperature", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.response.msg).toMatch /[0-9]+ degrees/gi

      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.weather"

  it "should return the current temperature for the specific location and default time", () ->
    query "temperature in syracuse", session: [], (r1) ->
      query "how hot will it be in syracuse", session: [], (r2) ->
        query "how cold will it be in syracuse", session: [], (r3) ->

          # all requests should be fully defined
          expect(r1.response.msg).toBeDefined()
          expect(r1.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r1.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r1.datapoints.by).toBeDefined()
          expect(r1.datapoints.by).toEqual "nlp.weather"

          expect(r2.response.msg).toBeDefined()
          expect(r2.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r2.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r2.datapoints.by).toBeDefined()
          expect(r2.datapoints.by).toEqual "nlp.weather"

          expect(r3.response.msg).toBeDefined()
          expect(r3.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r3.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r3.datapoints.by).toBeDefined()
          expect(r3.datapoints.by).toEqual "nlp.weather"

          # and should be equal
          expect(r1.response.msg).toEqual r2.response.msg
          expect(r2.response.msg).toEqual r3.response.msg

  it "should return the current temperature for the default location and specific time", () ->
    query "temperature tomorrow", session: [], (r1) ->
      query "how hot will it be tomorrow", session: [], (r2) ->
        query "how cold will it be tomorrow", session: [], (r3) ->

          # all requests should be fully defined
          expect(r1.response.msg).toBeDefined()
          expect(r1.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r1.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r1.datapoints.by).toBeDefined()
          expect(r1.datapoints.by).toEqual "nlp.weather"

          expect(r2.response.msg).toBeDefined()
          expect(r2.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r2.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r2.datapoints.by).toBeDefined()
          expect(r2.datapoints.by).toEqual "nlp.weather"

          expect(r3.response.msg).toBeDefined()
          expect(r3.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r3.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r3.datapoints.by).toBeDefined()
          expect(r3.datapoints.by).toEqual "nlp.weather"

          # and should be equal
          expect(r1.response.msg).toEqual r2.response.msg
          expect(r2.response.msg).toEqual r3.response.msg

  it "should return the current temperature for the specific location and specific time", () ->
    query "temperature tomorrow in syracuse", session: [], (r1) ->
      query "how hot will it be tomorrow in syracuse", session: [], (r2) ->
        query "how cold will it be tomorrow in syracuse", session: [], (r3) ->

          # all requests should be fully defined
          expect(r1.response.msg).toBeDefined()
          expect(r1.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r1.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r1.datapoints.by).toBeDefined()
          expect(r1.datapoints.by).toEqual "nlp.weather"

          expect(r2.response.msg).toBeDefined()
          expect(r2.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r2.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r2.datapoints.by).toBeDefined()
          expect(r2.datapoints.by).toEqual "nlp.weather"

          expect(r3.response.msg).toBeDefined()
          expect(r3.response.msg).toMatch /high [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r3.response.msg).toMatch /low [a-zA-Z\,\;\: ]* [0-9]+ degrees/gi
          expect(r3.datapoints.by).toBeDefined()
          expect(r3.datapoints.by).toEqual "nlp.weather"

          # and should be equal
          expect(r1.response.msg).toEqual r2.response.msg
          expect(r2.response.msg).toEqual r3.response.msg

describe "humidity weather operations", () ->

  it "should return the current humidity for the default location and current time", () ->
    query "humidity", session: [], (r) ->
      expect(r.response.msg).toBeDefined()
      expect(r.datapoints.by).toBeDefined()
      expect(r.datapoints.by).toEqual "nlp.weather"

class window.Complex
  constructor: (@re, @im) ->

  conjugate: ->
    im = -im
    return
    
  add: (c) ->
    @re += c.re
    @im += c.im
    return
    
  multiply: (c) ->
    tr = @re * c.re - @im * c.im
    ti = @re * c.im + @im * c.re
    @re = tr
    @im = ti
    return
    
  divide: (c) ->
    tr = @re * c.re + @im * c.im
    ti = @im * c.re - @re * c.im
    tmp = c.re * c.re + c.im * c.im
    @re = tr / tmp
    @im = ti / tmp
    
  minus: ->
    @re = -@re
    @im = -@im
    return
    
  abs: ->
    return Math.sqrt(@re * @re + @im * @im)

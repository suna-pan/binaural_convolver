$ ->
  iconSoundSourceWidth  = 32
  iconSoundSourceHeight = 60

  circleR  = 115
  circleR2 = 135
  clickErr = 50

  azimuthCenterX = 458
  azimuthCenterY = 162
  elevCenterX    = 140
  elevCenterY    = 140


  window.thAzimuth = 0
  window.thElev    = 0
  thGuide   = 0



  setSoundSourceIconPos = ->
    x = circleR2 * Math.cos((window.thAzimuth - 90) * Math.PI / 180.0) - iconSoundSourceWidth / 2
    y = circleR2 * Math.sin((window.thAzimuth - 90) * Math.PI / 180.0) - iconSoundSourceHeight / 2
    $('#sound_source_angle').css('margin-top', azimuthCenterY + y)
    $('#sound_source_angle').css('margin-left', azimuthCenterX + x)
    $('#sound_source_angle').css({transform:'rotate(' + window.thAzimuth + 'deg)'})

    x = circleR2 * Math.cos((window.thElev - 180) * Math.PI / 180.0) - iconSoundSourceWidth / 2
    y = circleR2 * Math.sin((window.thElev - 180) * Math.PI / 180.0) - iconSoundSourceHeight / 2
    $('#sound_source_elev').css('margin-top', elevCenterY + y)
    $('#sound_source_elev').css('margin-left', elevCenterX + x)
    $('#sound_source_elev').css({transform:'rotate(' + (window.thElev - 90) + 'deg)'})


  setSoundSourceGuidePos = (offsetX, offsetY, offsetTh, offsetRot) ->
    x = circleR2 * Math.cos((thGuide + offsetTh) * Math.PI / 180.0) - iconSoundSourceWidth / 2
    y = circleR2 * Math.sin((thGuide + offsetTh) * Math.PI / 180.0) - iconSoundSourceHeight / 2
    $('#sound_source_guide').css('margin-top', offsetY + y)
    $('#sound_source_guide').css('margin-left', offsetX + x)
    $('#sound_source_guide').css({transform:'rotate(' + (thGuide + offsetRot) + 'deg)'})


  calcTh5 = (dx, dy, offset) ->
    th = Math.atan2(dy, dx)
    th = th / Math.PI * 180
    if th < 0
      th += 360
    return Math.floor(((th + offset) % 360 + 2) / 5) * 5


  $('#sound_source_area_listener').on('click',
    (e) ->
      dx = e.offsetX - azimuthCenterX
      dy = e.offsetY - azimuthCenterY
      azimuthDist = Math.sqrt(dx * dx + dy * dy)
      if azimuthDist >= circleR && azimuthDist <= circleR + clickErr
        window.thAzimuth = calcTh5(dx, dy, 90.5)

      dx = e.offsetX - elevCenterX
      dy = e.offsetY - elevCenterY
      elevDist = Math.sqrt(dx * dx + dy * dy)
      if elevDist >= circleR && elevDist <= circleR + clickErr
        tmp = window.thElev
        window.thElev = calcTh5(dx, dy, 180.5)
        if window.thElev > 180
          window.thElev -= 360
        if window.thElev < -45 || window.thElev > 90
          window.thElev = tmp

      setSoundSourceIconPos()

  )


  $('#sound_source_area_listener').on('mousemove',
    (e) ->
      dx = e.offsetX - azimuthCenterX
      dy = e.offsetY - azimuthCenterY
      azimuthDist = Math.sqrt(dx * dx + dy * dy)
      if azimuthDist >= circleR && azimuthDist <= circleR + clickErr
        thGuide = calcTh5(dx, dy, 90.5)
        if thGuide != window.thAzimuth
          setSoundSourceGuidePos(azimuthCenterX, azimuthCenterY, -90, 0)
          $('#sound_source_guide').show()
        else
          $('#sound_source_guide').hide()
        return

      dx = e.offsetX - elevCenterX
      dy = e.offsetY - elevCenterY
      elevDist = Math.sqrt(dx * dx + dy * dy)
      if elevDist >= circleR && elevDist <= circleR + clickErr
        thGuide = calcTh5(dx, dy, 180.5)
        if thGuide > 180
          thGuide -= 360
        if thGuide < -45 || thGuide > 90
          $('#sound_source_guide').hide()
          return
        if thGuide != window.thElev
          setSoundSourceGuidePos(elevCenterX, elevCenterY, -180, -90)
          $('#sound_source_guide').show()
        else
          $('#sound_source_guide').hide()
        return

      $('#sound_source_guide').hide()
      return
  )


  $('#sound_source_area_listener').on('mouseout',
    (e) ->
      $('#sound_source_guide').hide()
  )


  setSoundSourceIconPos()
  $('#sound_source_guide').hide()





// Generated by CoffeeScript 1.10.0
(function() {
  $(function() {
    var azimuthCenterX, azimuthCenterY, calcTh5, circleR, circleR2, clickErr, elevCenterX, elevCenterY, iconSoundSourceHeight, iconSoundSourceWidth, setSoundSourceGuidePos, setSoundSourceIconPos, thGuide;
    iconSoundSourceWidth = 32;
    iconSoundSourceHeight = 60;
    circleR = 115;
    circleR2 = 135;
    clickErr = 50;
    azimuthCenterX = 458;
    azimuthCenterY = 162;
    elevCenterX = 140;
    elevCenterY = 140;
    window.thAzimuth = 0;
    window.thElev = 0;
    thGuide = 0;
    setSoundSourceIconPos = function() {
      var x, y;
      x = circleR2 * Math.cos((window.thAzimuth - 90) * Math.PI / 180.0) - iconSoundSourceWidth / 2;
      y = circleR2 * Math.sin((window.thAzimuth - 90) * Math.PI / 180.0) - iconSoundSourceHeight / 2;
      $('#sound_source_angle').css('margin-top', azimuthCenterY + y);
      $('#sound_source_angle').css('margin-left', azimuthCenterX + x);
      $('#sound_source_angle').css({
        transform: 'rotate(' + window.thAzimuth + 'deg)'
      });
      x = circleR2 * Math.cos((window.thElev - 180) * Math.PI / 180.0) - iconSoundSourceWidth / 2;
      y = circleR2 * Math.sin((window.thElev - 180) * Math.PI / 180.0) - iconSoundSourceHeight / 2;
      $('#sound_source_elev').css('margin-top', elevCenterY + y);
      $('#sound_source_elev').css('margin-left', elevCenterX + x);
      return $('#sound_source_elev').css({
        transform: 'rotate(' + (window.thElev - 90) + 'deg)'
      });
    };
    setSoundSourceGuidePos = function(offsetX, offsetY, offsetTh, offsetRot) {
      var x, y;
      x = circleR2 * Math.cos((thGuide + offsetTh) * Math.PI / 180.0) - iconSoundSourceWidth / 2;
      y = circleR2 * Math.sin((thGuide + offsetTh) * Math.PI / 180.0) - iconSoundSourceHeight / 2;
      $('#sound_source_guide').css('margin-top', offsetY + y);
      $('#sound_source_guide').css('margin-left', offsetX + x);
      return $('#sound_source_guide').css({
        transform: 'rotate(' + (thGuide + offsetRot) + 'deg)'
      });
    };
    calcTh5 = function(dx, dy, offset) {
      var th;
      th = Math.atan2(dy, dx);
      th = th / Math.PI * 180;
      if (th < 0) {
        th += 360;
      }
      return Math.floor(((th + offset) % 360 + 2) / 5) * 5;
    };
    $('#sound_source_area_listener').on('click', function(e) {
      var azimuthDist, dx, dy, elevDist, tmp;
      dx = e.offsetX - azimuthCenterX;
      dy = e.offsetY - azimuthCenterY;
      azimuthDist = Math.sqrt(dx * dx + dy * dy);
      if (azimuthDist >= circleR && azimuthDist <= circleR + clickErr) {
        window.thAzimuth = calcTh5(dx, dy, 90.5);
      }
      dx = e.offsetX - elevCenterX;
      dy = e.offsetY - elevCenterY;
      elevDist = Math.sqrt(dx * dx + dy * dy);
      if (elevDist >= circleR && elevDist <= circleR + clickErr) {
        tmp = window.thElev;
        window.thElev = calcTh5(dx, dy, 180.5);
        if (window.thElev > 180) {
          window.thElev -= 360;
        }
        if (window.thElev < -45 || window.thElev > 90) {
          window.thElev = tmp;
        }
      }
      return setSoundSourceIconPos();
    });
    $('#sound_source_area_listener').on('mousemove', function(e) {
      var azimuthDist, dx, dy, elevDist;
      dx = e.offsetX - azimuthCenterX;
      dy = e.offsetY - azimuthCenterY;
      azimuthDist = Math.sqrt(dx * dx + dy * dy);
      if (azimuthDist >= circleR && azimuthDist <= circleR + clickErr) {
        thGuide = calcTh5(dx, dy, 90.5);
        if (thGuide !== window.thAzimuth) {
          setSoundSourceGuidePos(azimuthCenterX, azimuthCenterY, -90, 0);
          $('#sound_source_guide').show();
        } else {
          $('#sound_source_guide').hide();
        }
        return;
      }
      dx = e.offsetX - elevCenterX;
      dy = e.offsetY - elevCenterY;
      elevDist = Math.sqrt(dx * dx + dy * dy);
      if (elevDist >= circleR && elevDist <= circleR + clickErr) {
        thGuide = calcTh5(dx, dy, 180.5);
        if (thGuide > 180) {
          thGuide -= 360;
        }
        if (thGuide < -45 || thGuide > 90) {
          $('#sound_source_guide').hide();
          return;
        }
        if (thGuide !== window.thElev) {
          setSoundSourceGuidePos(elevCenterX, elevCenterY, -180, -90);
          $('#sound_source_guide').show();
        } else {
          $('#sound_source_guide').hide();
        }
        return;
      }
      $('#sound_source_guide').hide();
    });
    $('#sound_source_area_listener').on('mouseout', function(e) {
      return $('#sound_source_guide').hide();
    });
    setSoundSourceIconPos();
    return $('#sound_source_guide').hide();
  });

}).call(this);
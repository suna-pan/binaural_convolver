$ ->
  file = null
  src_wav = null

  playing = false
  

  count    = 0
  waveSize = 0
  volume   = 1.0
  audio    = new Audio()

  audio_pause = ->
    audio.pause()
    playing = false
    $('#audio_play').children('img').attr('src', 'icon_play.png')


  audio_play = ->
    audio.play()
    playing = true
    $('#audio_play').children('img').attr('src', 'icon_pause.png')


  audio_update_time = (reset)->
    if reset
      $('#audio_time').text('00:00/00:00')
      return
    cm = Math.floor(audio.currentTime / 60)
    cs = Math.floor(audio.currentTime) % 60
    mm = Math.floor(audio.duration / 60)
    ms = Math.floor(audio.duration) % 60

    if isNaN(mm)
      mm = 0
    if isNaN(ms)
      ms = 0
    $('#audio_time').text(('0' + cm).slice(-2) + ':' + ('0' + cs).slice(-2) + '/' + ('0' + mm).slice(-2) + ':' + ('0' + ms).slice(-2))

  
  $('#file_selecter').change ->
    file = this.files[0]
    
    if file == null
      alert 'ファイルを選択してください'
      return
    
    src_wav = new window.WavFile(file)

    wav_load_sccuess = (header) ->
      if header.fmtSamplingRate != 44100 || header.fmtBitPerSample != 16
        alert '16bit 44100Hz のWAVファイルを選択してください'
        filie = null
      waveSize = Math.ceil(header.fmtWaveSize / 2 / header.fmtCh / 512)

    wav_load_fail = (code) ->
      if code == 1
        alert '非対応ブラウザです'
      if code == 2
        alert 'wavファイルを選択してください'
    
    src_wav.loadHeader(wav_load_sccuess, wav_load_fail)


  $('#exec_button').click ->
    if file == null
      alert 'ファイルを選択してください'
      return

    $('#exec_button').prop('disabled', true)

    audio_pause();
    $('#audio_play').prop('disabled', true)
    $('#audio_stop').prop('disabled', true)
    $('#audio_dl').prop('disabled', true)
    $('#audio_position').slider({
      max: 0,
      value: 0
    })
    audio_update_time(true)
    $('#audio_controller').css({
      opacity: '0.3'
    })

    $.getJSON('/json/0e270a.json',
      (data) ->
        hrtfL = []
        hrtfR = []
        for i in [0...1024]
          hrtfL.push(new Complex(data.hL[i].re, data.hL[i].im))
          hrtfR.push(new Complex(data.hR[i].re, data.hR[i].im))

        loadWavFail = ->
          alert 'WAVファイルのロードに失敗しました'
          $('#exec_button').prop('disabled', false)
          $('#selected_filename').text('ファイルを選択してください')
          file = null

        oldBufL = []
        oldBufR = []
        resultWav = ''
        loadWavFirst = (last, result, refSize) ->
          if last
            alert 'ファイルが短すぎます'
            $('#exec_button').prop('disabled', false)
            $('#selected_filename').text('ファイルを選択してください')
            file = null
            return

          for i in result
            oldBufL.push(new Complex(i[0].re, i[0].im))
            oldBufR.push(new Complex(i[1].re, i[1].im))

          $('#exec_button').attr('value', '処理中')
          count = 0
          loadWavLoop = (last, result, refSize) ->
            count++
            progress = Math.floor(count / waveSize * 100)
            $('#exec_button').css({
              background: "linear-gradient(to right, #505050 0%, #505050 " +  progress+ "%, #202020 " + progress + "%, #202020 100%)"
            });

            bufL = []
            bufR = []
            for i in [0...512]
              bufL.push(new Complex(oldBufL[i].re, oldBufL[i].im))
              bufR.push(new Complex(oldBufR[i].re, oldBufR[i].im))

            oldBufL = []
            oldBufR = []
            for i in result
              bufL.push(new Complex(i[0].re, i[0].im))
              bufR.push(new Complex(i[1].re, i[1].im))
              oldBufL.push(new Complex(i[0].re, i[0].im))
              oldBufR.push(new Complex(i[1].re, i[1].im))
            if last
              while bufL.length != 1024
                bufL.push(new Complex(0, 0))
                bufR.push(new Complex(0, 0))
                oldBufL.push(new Complex(0, 0))
                oldBufR.push(new Complex(0, 0))
            
            
            convol = ->
              fft1024(bufL)
              fft1024(bufR)
            
              for i in [0...1024]
                bufL[i].multiply(hrtfL[i])
                bufR[i].multiply(hrtfR[i])
              
              ifft1024(bufL)
              ifft1024(bufR)

              for i in [512...1024]
                bl = Math.round(bufL[i].re)
                br = Math.round(bufR[i].re)
                resultWav += String.fromCharCode(bl & 0xff, (bl >> 8) & 0xff)
                resultWav += String.fromCharCode(br & 0xff, (br >> 8) & 0xff)
            
            convol()
            
            if last
              bufL = []
              bufR = []
              for i in [0...512]
                bufL.push(new Complex(oldBufL[i].re, oldBufL[i].im))
                bufR.push(new Complex(oldBufR[i].re, oldBufR[i].im))
              for i in [0...512]
                bufL.push(new Complex(0, 0))
                bufR.push(new Complex(0, 0))
                
              convol()
              wav = btoa(src_wav.genWavHeader(resultWav.length) + resultWav)
              audio.src = 'data:audio/wav;base64,' + wav
              $('#exec_button').attr('value', '実行する')
              $('#exec_button').css({
                background: ''
              });
              $('#exec_button').prop('disabled', false)
              $('#audio_play').prop('disabled', false)
              $('#audio_stop').prop('disabled', false)
              $('#audio_dl').prop('disabled', false)
              $('#audio_controller').css({
                opacity: ''
              })
              $('#selected_filename').text('ファイルを選択してください')
              file = null
            else
              src_wav.next512(loadWavLoop, loadWavFail)

          src_wav.next512(loadWavLoop, loadWavFail)

        src_wav.next512(loadWavFirst, loadWavFail)
    ).fail(
      ->
        alert 'HRTFのダウンロードに失敗しました'
        $('#exec_button').prop('disabled', false)
        $('#selected_filename').text('ファイルを選択してください')
        file = null
    )


  $('#audio_play').click(
    (e) ->
      if playing
        audio_pause()
      else
        audio_play()
  )


  $('#audio_stop').click(
    (e) ->
      audio_pause()
      audio.currentTime = 0
  )


  $('#audio_position').slider({
    value: 0,
    min: 0,
    max: 0,
    step: 1,
    range: 'min',
    stop:
      (event, ui) ->
        audio.currentTime = ui.value / 1000
  })


  $('#audio_volume').slider({
    value: 1000,
    min: 0,
    max: 1000,
    step: 1,
    range: 'min',
    slide:
      (event, ui) ->
        audio.volume = ui.value / 1000
        volume = audio.volume
  })


  audio.addEventListener('durationchange',
    ->
      $('#audio_position').slider({ max: Math.ceil(audio.duration * 1000)})
  , false)


  audio.addEventListener('canplaythrough',
    ->
      audio_update_time(false)
  , false)


  audio.addEventListener('timeupdate',
    ->
      $('#audio_position').slider({ value: Math.ceil(audio.currentTime * 1000)})
      audio_update_time(false)
  , false)
  

  audio.addEventListener('ended',
    ->
      audio_pause()
      audio.currentTime = 0
  , false)


  $('#audio_controller').css({
    opacity: '0.3'
  })
  $('#audio_play').prop('disabled', true)
  $('#audio_stop').prop('disabled', true)
  $('#audio_dl').prop('disabled', true)
  $('#audio_position').slider({
    max: 0,
    value: 0
  })


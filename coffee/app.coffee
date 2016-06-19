$ ->
  file = null
  src_wav = null

  playing = false
  
  audio = new Audio()
  
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

    wav_load_fail = (code) ->
      if code == 1
        alert '非対応ブラウザです'
      if code == 2
        alert 'wavファイルを選択してください'
    
    src_wav.loadHeader(wav_load_sccuess, wav_load_fail)


  $('#exec_button').click ->
    console.log('Start')
    if file == null
      alert 'ファイルを選択してください'
      return

    $.getJSON('/json/0e270a.json',
      (data) ->
        hrtfL = []
        hrtfR = []
        for i in [0...1024]
          hrtfL.push(new Complex(data.hL[i].re, data.hL[i].im))
          hrtfR.push(new Complex(data.hR[i].re, data.hR[i].im))

        loadWavFail = ->
          alert 'WAVファイルのロードに失敗しました'
          file = null

        oldBufL = []
        oldBufR = []
        resultWav = ''
        loadWavFirst = (last, result, refSize) ->
          if last
            alert 'ファイルが短すぎます'
            file = null
            return

          for i in result
            oldBufL.push(new Complex(i[0].re, i[0].im))
            oldBufR.push(new Complex(i[1].re, i[1].im))

          count = 0
          loadWavLoop = (last, result, refSize) ->
            count++
            console.log('loop ' + count)

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

            else
              src_wav.next512(loadWavLoop, loadWavFail)

          src_wav.next512(loadWavLoop, loadWavFail)

        src_wav.next512(loadWavFirst, loadWavFail)
    ).fail(
      ->
        alert 'HRTFのダウンロードに失敗しました'
        file = null
    )


  $('#audio_play').click(
    (e) ->
      if playing
        audio.pause()
        playing = false
        $('#audio_play').children('img').attr('src', 'icon_play.png')
      else
        audio.play()
        playing = true
        $('#audio_play').children('img').attr('src', 'icon_pause.png')
  )


  $('#audio_stop').click(
    (e) ->
      audio.pause()
      audio.currentTime = 0
      playing = false
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


  audio.addEventListener('durationchange'
    ->
      $('#audio_position').slider({ max: Math.ceil(audio.duration * 1000)})
      
  , false)


  audio.addEventListener('timeupdate'
    ->
      $('#audio_position').slider({ value: Math.ceil(audio.currentTime * 1000)})
  , false)
  
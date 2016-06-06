$ ->
  file = null
  src_wav = null
  
  audio = document.getElementById("audio")
  
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


  $('#exec').click ->
    console.log('Start')
    if file == null
      alert 'ファイルを選択してください'
      return

    $.getJSON('/json/0e270a.json',
      (data) ->
        hrtfL = []
        hrtfR = []
        for i in 1024
          hrtfL.push(new Complex(data.hL[i].re, data.hL[i].im))
          hrtfR.push(new Complex(data.hR[i].re, data.hR[i].im))
          
        loadWavFail = ->
          alert 'WAVファイルのロードに失敗しました'
          file = null

        bufL = [0...512]
        bufR = [0...512]
        resultWav = ''
        loadWavFirst = (last, result, refSize) ->
          if last
            alert 'ファイルが短すぎます'
            file = null
            return

          for i in result
            bufL.push(new Complex(i[0].re, i[0].im))
            bufR.push(new Complex(i[1].re, i[1].im))
            
          loadWavLoop = (last, result, refSize) ->
            bufL = bufL.slice(512,1024)
            bufR = bufR.slice(512,1024)
            for i in result
              bufL.push(new Complex(i[0].re, i[0].im))
              bufR.push(new Complex(i[1].re, i[1].im))
            if last
              while bufL.length != 1024
                bufL.push(new Complex(0, 0))
              while bufR.length != 1024
                bufL.push(new Complex(0, 0))
            
            
            convol = ->    
              fft1024(bufL)
              fft1024(bufR)
            
              for i in [0...1024]
                bufL[i].multiply(hrtfL[i])
                bufR[i].multiply(hrtfR[i])
              
              ifft1024(bufL)
              ifft1024(bufR)
            
              for i in [512...1024]
                resultWav += String.fromCharCode(bufL[i].re & 0xff, (bufL[i].re >> 8) & 0xff)
                resultWav += String.fromCharCode(bufR[i].re & 0xff, (bufR[i].re >> 8) & 0xff)
            
            convol()
            
            if last
              bufL = bufL.slice(512,1024)
              bufR = bufR.slice(512,1024)
              for i in [0...512]
                bufL.push(new Complex(0, 0))
                bufR.push(new Complex(0, 0))
                
              convol()
              wav = btoa(src_wav.genWavHeader(resultWav.length) + resultWav)
            else
              src_wav.next512(loadWavLoop, loadWavFail)
        
        src_wav.next512(loadWavFirst, loadWavFail)
    ).fail(
      ->
        alert 'HRTFのダウンロードに失敗しました'
        file = null
    )

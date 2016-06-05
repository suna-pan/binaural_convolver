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
    
    bytes = ''
    wav_load_sccuess = (header) ->
      sc = (last, result, refSize) ->
        for i in result
          bytes += String.fromCharCode(i[0].re & 0xff, (i[0].re >> 8) & 0xff)
          bytes += String.fromCharCode(i[1].re & 0xff, (i[1].re >> 8) & 0xff)
        if last
          wav = btoa(src_wav.genWavHeader(bytes.length) + bytes)
          audio.src = 'data:audio/wav;base64,' + wav
        else
          src_wav.next512(sc, null)
          
      src_wav.next512(sc, null)
      
      

    wav_load_fail = (code) ->
      if code == 1
        alert '非対応ブラウザです'
      if code == 2
        alert 'wavファイルを選択してください'
    
    src_wav.loadHeader(wav_load_sccuess, wav_load_fail)
       

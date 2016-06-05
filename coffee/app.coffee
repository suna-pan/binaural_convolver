$ ->
  file = null
  src_wav = null
  
  
  $('#file_selecter').change ->
    file = this.files[0]
    
    if file == null
      alert 'ファイルを選択してください'
      return
    
    src_wav = new window.WavFile(file)
    
    wav_load_sccuess = (header) ->
      sc = (last, result, refSize) ->
        if last
          alert result[result.length - 1][0].re + ' ' + result[result.length - 1][0].im
        else
          src_wav.next512(sc, null)
          
      src_wav.next512(sc, null)
      
      

    wav_load_fail = (code) ->
      if code == 1
        alert '非対応ブラウザです'
      if code == 2
        alert 'wavファイルを選択してください'
    
    src_wav.loadHeader(wav_load_sccuess, wav_load_fail)
       

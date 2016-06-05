WAV_HEADER_LENGTH = 45

class window.WavFile
  @header = null

  constructor: (@file) ->
  
  littleEndian = (data) ->
    res = 0
    shift = 0
    for d in data
      res += d << shift
      shift += 8

    return res
    
  
  loadHeader: (success, fail)->
    reader = new FileReader()
    reader.onloadend = (evt) ->
      if evt.target.readyState != FileReader.DONE
        return

      raw = evt.target.result
      data = new Uint8Array(raw)

      if data.length != WAV_HEADER_LENGTH
        fail(2)
        return
      
      strRIFF = String.fromCharCode.apply("", data.slice(0, 4))
      if strRIFF != "RIFF"
        fail(2)
        return
      
      strWAVE = String.fromCharCode.apply("", data.slice(8, 12))
      if strWAVE != "WAVE"
        fail(2)
        return
        
      strData = String.fromCharCode.apply("", data.slice(36, 40))
      if strData != "data"
        fail(2)
        return

      fileSize = littleEndian.call(@, data.slice(4, 8))
      fmtSize  = littleEndian.call(@, data.slice(16, 20))
      fmtCode  = littleEndian.call(@, data.slice(20, 22))
      fmtCh    = littleEndian.call(@, data.slice(22, 24))
      fmtSamplingRate = littleEndian.call(@, data.slice(24, 28))
      fmtBytePerSec   = littleEndian.call(@, data.slice(28, 32))
      fmtBlockBound   = littleEndian.call(@, data.slice(32, 34))
      fmtBitPerSample = littleEndian.call(@, data.slice(34, 36))

      @header = {
        fileSize: fileSize + 8,
        fmtSize:  fmtSize,
        fmtCode:  fmtCode,
        fmtCh:    fmtCh,
        fmtSamplingRate: fmtSamplingRate,
        fmtBytePerSec:   fmtBytePerSec,
        fmtBlockBound:   fmtBlockBound,
        fmtBitPerSample: fmtBitPerSample
      }
      
      success(@header)
    
    start = 0
    stop  = WAV_HEADER_LENGTH
    blob  = null
    if @file.webkitSlice
      blob = @file.webkitSlice(start, stop)
    else if @file.mozSlice
      blob = @file.mozSlice(start, stop)
    else
      blob = @file.slice(start, stop)
 
    if blob != null
      reader.readAsArrayBuffer(blob)
    else
      fail(1)
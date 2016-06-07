WAV_HEADER_LENGTH = 45

class window.WavFile
  constructor: (@file) ->
    @header = null
    @current = WAV_HEADER_LENGTH - 1

  littleEndian = (data) ->
    res = 0
    shift = 0
    for d in data
      res += d << shift
      shift += 8

    return res


  loadHeader: (success, fail)->
    me = this
    setHeader = (h) ->
      me.header = h

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
      fmtWaveSize     = littleEndian.call(@, data.slice(40, 44))

      h = {
        fileSize: fileSize + 8,
        fmtSize:  fmtSize,
        fmtCode:  fmtCode,
        fmtCh:    fmtCh,
        fmtSamplingRate: fmtSamplingRate,
        fmtBytePerSec:   fmtBytePerSec,
        fmtBlockBound:   fmtBlockBound,
        fmtBitPerSample: fmtBitPerSample,
        fmtWaveSize:     fmtWaveSize
      }

      setHeader(h)
      success(h)

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

  next512: (success, fail) ->
    blockBound = @header.fmtBlockBound
    bytePerSample = @header.fmtBitPerSample / 8
    bp2 = bytePerSample * 2
    ch = @header.fmtCh
    refSize = bytePerSample * 512 * ch
    last = false

    reader = new FileReader()
    reader.onloadend = (evt) ->
      raw = evt.target.result
      data = new Uint8Array(raw)

      result = [0...data.length / (ch * bytePerSample)]
      for i in [0...data.length / (ch * bytePerSample)]
        if ch == 1
          tmp = new window.Complex(littleEndian.call(@, data.slice(i * blockBound, i * blockBound + bytePerSample)), 0)
          result[i] = [tmp, tmp]
        else
          tmpL = littleEndian.call(@, data.slice(i * blockBound, i * blockBound + bytePerSample))
          tmpR = littleEndian.call(@, data.slice(i * blockBound + bytePerSample, i * blockBound + bp2))
          result[i] = [new window.Complex(tmpL, 0), new window.Complex(tmpR, 0)]
          
        if result[i][0].re > 0x0ffff
          result[i][0].re = ~(result[i][0].re - 1)
        if result[i][1].re > 0x0ffff
          result[i][1].re = ~(result[i][1].re - 1)
          
       success(last, result, refSize)
    
    start = @current
    stop  = @current + 512 * @header.fmtBlockBound
    @current = stop
        
    if @current - (WAV_HEADER_LENGTH - 1) >= @header.fmtWaveSize
      last = true

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

  # 16bit 44100Hz
  genWavHeader: (waveSize) ->
    fileSize = waveSize + WAV_HEADER_LENGTH - 8
    buf  = String.fromCharCode(0x52, 0x49, 0x46, 0x46)
    buf += String.fromCharCode(fileSize & 0xff, (fileSize >> 8) & 0xff, (fileSize >> 16) & 0xff, (fileSize >> 24) & 0xff)
    buf += String.fromCharCode(0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20,
                               0x10, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00,
                               0x44, 0xac, 0x00, 0x00, 0x10, 0xb1, 0x02, 0x00
                               0x04, 0x00, 0x10, 0x00, 0x64, 0x61, 0x74, 0x61)
    buf += String.fromCharCode(waveSize & 0xff, (waveSize >> 8) & 0xff, (waveSize >> 16) & 0xff, (waveSize >> 24) & 0xff)
    return buf

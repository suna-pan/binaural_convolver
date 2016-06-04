window.fft_base = (N, log2N, data, index, w) ->
  interval = 1
  for i in [0...log2N]
    _k = 0
    interval *= 2
  
    while _k < N
      w_kn = new window.Complex(1, 0)
      interval_h = interval / 2
    
      for k in [0...interval_h]
        index1 = index[(_k + k) % N]
        index2 = index[(_k + k + interval_h) % N]
        data[index2].multiply(w_kn)
        tmp = new window.Complex(data[index1].re, data[index1].im)
        data[index1].add(data[index2])
        data[index2].minus()
        data[index2].add(tmp)
        w_kn.multiply(w[i])
    
      _k += interval
      
  res = [0...1024]
  for i in [0...1024]
    res[i] = data[d_index[i]]
  
  data = res
  
  
      
window.fft1024 = (data) ->
  fft_base(1024, 10, data, window._fft_const_index, window._fft_const_w)


window.ifft1024 = (data) ->
  fft_base(1024, 10, data, window._fft_const_index, window._fft_const_iw)
  d = new window.Complex(1024, 0)
  for i in data
    i.divide(d)
    
# coding: UTF-8

begin
  Dir.mkdir('res')
rescue
end



w = []

w << Complex(-1.0)
(10 - 1).times do |i|
  n = 2 ** (i + 2)
  z = -2 * Math::PI / n
  w << Complex(Math::cos(z), Math::sin(z))
end

index = []
1024.times do |i|
  t = 0
  10.times do
    t |= i[0]
    i = i >> 1
    t = t << 1
  end
  t = t >> 1
  index << t
end




def fft(fname, index, w)
  r = []
  f = open(fname)

  f.each_line do |l|
    r << Complex(l.to_f)
  end
  f.close

  512.times do
    r << Complex(0)
  end


  itv = 1
  10.times do |i|
    _k = 0
    itv *= 2
    while _k < 1024
      ww = 1
      itv2 = itv / 2
        itv2.times do |k|
        idx1 = index[(_k + k) % 1024]
        idx2 = index[(_k + k) + itv2 % 1024]
        r[idx2] *= ww
        tmp = r[idx1]
        r[idx1] += r[idx2]
        r[idx2] = -r[idx2] + tmp
        ww *= w[i]
      end
      _k += itv
    end
  end

  res = Array.new(1024)
  1024.times do |i|
    res[i] = r[index[i]]
  end

  res
end



elev = -45
while elev <= 90
  angle = 0
  while angle < 360
    dir = "elev%d/"%[elev]
    file   = "%de%03da.dat"%[elev, angle]
    fnameL = "L" + file
    fnameR = "R" + file

    resL = fft(dir + fnameL, index, w)
    resR = fft(dir + fnameR, index, w)

    json = "{\n"
    json += "point: 1023,\n"
    json += "samplingRate: 44100,\n"
    json += "elev: " + elev.to_s + ",\n"
    json += "angle: " + angle.to_s + ",\n"
    json += "hL: [\n"
    resL.each_with_index do |item, index|
      json += "{re: %f, im: %f}"%[item.real, item.imaginary]
      if index != 1023
        json += ','
      end
      json += "\n"
    end
    json += "],\n"

    json += "hR: [\n"
    resR.each_with_index do |item, index|
      json += "{re: %f, im: %f}"%[item.real, item.imaginary]
      if index != 1023
        json += ','
      end
      json += "\n"
    end
    json += "]\n"
    json += "}\n"

    out = open('res/' + file, 'w:UTF-8:UTF-8')
    out.puts(json)
    out.close

    angle += 5
  end

  elev += 5
end


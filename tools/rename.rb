ARGV.each do |item|
  new_name = item.split('.')[0] + '.json'
  puts new_name
  File.rename(item, new_name)
end
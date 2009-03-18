require File.join(File.dirname(__FILE__), "../../../../config/environment")

ARGV.each do |path|
  path = File.expand_path(path)
  header = File.open(path){|m| m.gets("\n\n")}
  mail = TMail::Mail.parse(header)
  list = mail.header_string("X-ML-Name")
  count = mail.header_string("X-Mail-Count")
  if list && count
    Article.create!(:list => list, :count => count, :path => path)
  end
end

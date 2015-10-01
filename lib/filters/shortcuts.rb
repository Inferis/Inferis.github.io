require 'Nokogiri'

class Shortcuts < Nanoc3::Filter
  def run(content, params={})
  	content = content.gsub('##shrug', "¯\\\_(ツ)\_\/¯")
  	content = content.gsub('##throwtable', "(╯°□°)╯︵ ┻━┻")
  	content = content.gsub('##apple', "")
  end
end

Nanoc3::Filter.register "Shortcuts", :shortcuts

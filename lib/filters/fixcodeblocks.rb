require 'Nokogiri'

class FixCodeBlocks < Nanoc3::Filter
  def run(content, params={})
    doc = Nokogiri::HTML.parse(content)
    doc.css('pre > code').each do |element|
      next unless element['class']
      element['class'] = "language-#{element['class']}"
    end
    doc.to_html
  end
end

Nanoc3::Filter.register "FixCodeBlocks", :fix_code_blocks

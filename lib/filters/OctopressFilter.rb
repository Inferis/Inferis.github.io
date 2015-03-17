class OctopressFilter < Nanoc3::Filter

  def tag_name
    raise "override tag_name"
  end

  def run(content, params={})
    tag = tag_name
    content.gsub(/\{\%\s*#{tag}(.*)?\%\}/) do |match|
      markup = /\{\%\s*#{tag}\s*(.*)?\s*\%\}/.match(match).captures[0]
      run_octopress(tag, markup, params)
    end
  end

  def run_octopress(tag_name, markup, params)
    "{% #{tag_name} #{markup} %}"
  end

end

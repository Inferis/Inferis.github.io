class OctopressFilter < Nanoc3::Filter

  @tag_name = ""

  def run(content, params={})
    content.gsub(/\{\%\s*#{@tag_name}(.*)\%\}/) do |match|
      markup = /\{\%\s*#{@tag_name}(.*)\%\}/.match(match).captures[0]
      run_octopress(@tag_name, markup, params)
    end
  end

  def run_octopress(tag_name, markup, params)
    "{% #{@tag_name} #{markup} %}"
  end

end

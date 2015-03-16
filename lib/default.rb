# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::LinkTo

def get_post_start(post)
  content = post.compiled_content
  if content =~ /\s<!-- more -->\s/
    content = content.partition('<!-- more -->').first
    content = content +
    "<div class='read-more'><a href='#{post.path}'>Continue reading &rsaquo;</a></div>"
  end

  return content
end

def item_is_asset?(item)
  item[:extension] == 'jpg' || item[:extension] == 'gif' || item[:extension] == 'png' ||
  item[:extension] == 'css' ||
  item[:extension] == 'js'
end

def is_post_published(post)
  post[:published].nil? ? true : post[:published]
end

def articles_by_month
  articles_to_group = sorted_articles.select { |a| is_post_published(a) }
  articles_to_group = articles_to_group.sort_by { |a| Time.parse("#{a[:created_at]}") }

  articles_to_group = articles_to_group.map do |a|
    begin
      time = Time.parse("#{a[:created_at]}")
      { :id => "#{time.year}/#{time.month.to_s.rjust(2, '0')}", :time => time }
    rescue
    end
  end

  articles_to_group = articles_to_group.uniq { |a| a[:id] }
end

def articles_for_month(id)
  articles_to_group = sorted_articles.sort_by { |a| Time.parse("#{a[:created_at]}") }

  articles_to_group = articles_to_group.map do |a|
    begin
      time = Time.parse("#{a[:created_at]}")
      { :id => "#{time.year}/#{time.month.to_s.rjust(2, '0')}", :item => a }
    rescue
    end
  end

  result = articles_to_group.select { |a| a[:id] == id }.map { |a| a[:item] }
end

def exclude_unpublished
  @items = @items.delete_if { |a| !is_post_published(a) }
end

def create_archives
  articles_by_month().each do |key|
    @items << Nanoc::Item.new(
      "<%= render 'archive_page', :id => \"#{key[:id]}\" %>",
      { :title => key[:time].strftime("Archive for %B %Y") },
      "/blog/#{key[:id]}/"
    )
  end
end

def formatted_date(date)
  begin
    date = Time.parse("#{date}")
    date.strftime("%B %d, %Y")
  rescue
    "an unknown time"
  end
end

# Based on Tweet Tag by Scott W. Bradley
# Source URL: https://github.com/scottwb/jekyll-tweet-tag
#
# Example usage:
#   {% tweet https://twitter.com/DEVOPS_BORAT/status/159849628819402752 %}

require 'json'
require 'uri'
require 'net/http'
require 'openssl'

class OctopressTweetTags < OctopressFilter

  TWITTER_OEMBED_URL = "https://api.twitter.com/1/statuses/oembed.json" unless TWITTER_OEMBED_URL

  def tag_name
    "tweet"
  end

  def run_octopress(tag_name, markup, params)
    @text           = markup
    @cache_folder   = File.expand_path "../.tweet-cache", File.dirname(__FILE__)
    @cache_disabled = false
    FileUtils.mkdir_p @cache_folder

    args       = @text.split(/\s+/).map(&:strip)
    api_params = {'url' => args.shift()}

    args.each do |arg|
      k,v = arg.split('=').map(&:strip)
      if k && v
        if v =~ /^'(.*)'$/
          v = $1
        end
        api_params[k] = v
      end
    end

    html_output_for(api_params)
  end

  def html_output_for(api_params)
    body = "Tweet could not be processed"
    if response = cached_response(api_params) || live_response(api_params)
      body = response['html'] || response['error'] || body
    end
    "<div class='embed tweet'>#{body}</div>"
  end

  def cache(api_params, data)
    cache_file = cache_file_for(api_params)
    File.open(cache_file, "w") do |f|
      f.write(data)
    end
  end

  def cached_response(api_params)
    return nil if @cache_disabled
    cache_file = cache_file_for(api_params)
    JSON.parse(File.read(cache_file)) if File.exist?(cache_file)
  end

  def url_params_for(api_params)
    api_params.keys.sort.map do |k|
      "#{CGI::escape(k)}=#{CGI::escape(api_params[k])}"
    end.join('&')
  end

  def cache_file_for(api_params)
    filename = "#{Digest::MD5.hexdigest(url_params_for(api_params))}.cache"
    File.join(@cache_folder, filename)
  end

  def live_response(api_params)
    api_uri = URI.parse(TWITTER_OEMBED_URL + "?#{url_params_for(api_params)}")
    http = Net::HTTP.new(api_uri.host, api_uri.port)
    http.use_ssl = true
    http.ssl_version = 'TLSv1'       # -- or SSLv3, but TLSv1 is better
    response = http.get(api_uri.request_uri).body
    cache(api_params, response) unless @cache_disabled
    JSON.parse(response)
  end
end


Nanoc3::Filter.register "OctopressTweetTags", :octopress_tweet_tags

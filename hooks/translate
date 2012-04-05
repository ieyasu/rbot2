#!/usr/bin/env ruby

require 'abbrev'

SYNTAX = 'Usage: !translate <src lang> [to] <dest lang> <phrase>'

VALID_PATHS = [
    "ar|en", "zh-CN|en", "en|ar", "en|zh-CN", "en|fr", "en|de", "en|it",
    "en|ja", "en|ko", "en|pt", "en|ru", "en|es", "fr|en", "fr|de", "de|en",
    "de|fr", "it|en", "ja|en", "ko|en", "pt|en", "ru|en", "es|en",
    "ar|en", "zh-CN|en", "en|ar", "en|zh-CN", "en|fr", "en|de", "en|it",
    "en|ja", "en|ko", "en|pt", "en|ru", "en|es", "fr|en", "fr|de", "de|en",
    "de|fr", "it|en", "ja|en", "ko|en", "pt|en", "ru|en", "es|en"
]
LANGS = [
    'arabic', 'chinese', 'english', 'french', 'german', 'italian',
    'japanese', 'korean', 'portuguese', 'russian', 'spanish'
]

def lang_to_code(lang)
    case Abbrev::abbrev(LANGS)[lang.downcase]
    when 'arabic'     then 'ar'
    when 'chinese'    then 'zh-CN'
    when 'english'    then 'en'
    when 'french'     then 'fr'
    when 'german'     then 'de'
    when 'italian'    then 'it'
    when 'japanese'   then 'ja'
    when 'korean'     then 'ko'
    when 'portuguese' then 'pt'
    when 'russian'    then 'ru'
    when 'spanish'    then 'es'
    end
end

def parse_args(args)
    if args =~ /([^ ]+) (?:to )?([^ ]+) (.+)/
        src, dest, text = $1, $2, $3
        src = lang_to_code(src) or return
        dest = lang_to_code(dest) or return
        path = "#{src}|#{dest}"
        return unless VALID_PATHS.member?(path)
        { 'text' => CGI.escape(text), 'langpair' => path,
            'hl' => 'en', 'ie' => 'UTF-8', 'oe' => 'UTF-8' }
    end
end

def parse_translation(body)
    i = body.index('<div id=result_box') or return
    j = body.index('</div>', i) or return
    "P\tTranslation: #{strip_html(body[i...j])}"
end

def handle_command(nick, dest, args)
    return "P\t#{SYNTAX}" unless args.length > 0

    unless (params = parse_args(args))
        args =~ /([^ ]+) (?:to )?([^ ]+)/
        return "P\tCannot translate from #{$1} to #{$2}"
    end

    uri = URI.parse('http://translate.google.com/translate_t')
    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data(params)
    req['User-Agent'] = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14'
    resp = Net::HTTP.new(uri.host, uri.port).start do |http|
        http.request(req)
    end
    #resp = Net::HTTP.post_form(uri, params)

    parse_translation(CGI.unescape(resp.body)) or
        "P\tError parsing translation"
end

load 'boilerplate.rb'

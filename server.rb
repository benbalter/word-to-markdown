require 'word-to-markdown'
require 'sinatra'
require 'kramdown'

module WordToMarkdownServer
  class App < Sinatra::Base

    get "/" do
      render_template :index, { :error => nil }
    end

    post "/" do
      if params['doc'][:filename].match /docx?$/
        error = "It looks like you tried to upload a Word Document. You must first export it as a web page."
        render_template :index, { :error => error }
      end
      md = WordToMarkdown.new(params['doc'][:tempfile]).to_s
      html = Kramdown::Document.new(md).to_html
      render_template :display, { :md => md, :html => html, :filename => params['doc'][:filename].sub(/\.html?$/,"") }
    end

    def render_template(template, locals={})
      halt erb template, :layout => :layout, :locals => locals
    end

  end
end

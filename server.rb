require 'word-to-markdown'
require 'sinatra'
require 'html/pipeline'
require 'rack/coffee'

module WordToMarkdownServer
  class App < Sinatra::Base

    use Rack::Coffee, root: 'public', urls: '/assets/javascripts'

    get "/" do
      render_template :index, { :error => nil }
    end

    post "/" do
      if params['doc'][:filename].match /docx?$/
        error = "It looks like you tried to upload a Word Document. You must first export it as a web page."
        render_template :index, { :error => error }
      end
      md = WordToMarkdown.new(params['doc'][:tempfile]).to_s
      html = HTML::Pipeline::MarkdownFilter.new(md).call
      render_template :display, { :md => md, :html => html, :filename => params['doc'][:filename].sub(/\.html?$/,"") }
    end

    post "/raw" do
      html = request.env["rack.request.form_vars"]
      WordToMarkdown.new("<!-- Prevent arbitrary file reads -->#{html}").to_s
    end

    def render_template(template, locals={})
      halt erb template, :layout => :layout, :locals => locals
    end

  end
end

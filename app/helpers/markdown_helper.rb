module MarkdownHelper

  # コードブロック シンタックスハイライト
  require 'rouge'
  require 'rouge/plugins/redcarpet'

  class RougeHTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end
  
  # markdown レンダリング
  def markdown(text)
      options = {
          hard_wrap: true,
          link_attributes: { rel: 'nofollow', taget: '_blank' },
          fenced_code_blocks: true,
          no_intra_emphasis: true,
          tasklist: true,
          autolink: true,
          tables: true,
          space_after_headers: true,
          underline: true,
          highlight: true,
          quote: true, 
          footnotes: true
      }
      markdown = Redcarpet::Markdown.new(RougeHTML, options)
      sanitize(markdown.render(text))
  end
  # markdown 目次
  def toc(text)
      renderer = Redcarpet::Render::HTML_TOC.new(nesting_level: 3)
      markdown = Redcarpet::Markdown.new(renderer)
      markdown.render(text).html_safe
  end
end
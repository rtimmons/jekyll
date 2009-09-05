module Jekyll

  class HighlightBlock < Liquid::Block
    include Liquid::StandardFilters

    # we need a language, but the linenos argument is optional.
    SYNTAX = /(\w+)\s?([\w\s=]+)*/

    def initialize(tag_name, markup, tokens)
      super
      if markup =~ SYNTAX
        @lang = $1
        if defined? $2
          tmp_options = {}
          $2.split.each do |opt|
            key, value = opt.split('=')
            if value.nil?
              if key == 'linenos'
                value = 'inline'
              else
                value = true
              end
            end
            tmp_options[key] = value
          end
          tmp_options = tmp_options.to_a.collect { |opt| opt.join('=') }
          # additional options to pass to Albino.
          @options = { 'O' => tmp_options.join(',') }
        else
          @options = {}
        end
      else
        raise SyntaxError.new("Syntax Error in 'highlight' - Valid syntax: highlight <lang> [linenos]")
      end
    end

    def render(context)
      if context.registers[:site].pygments
        render_pygments(context, super.to_s)
      else
        render_codehighlighter(context, super.to_s)
      end
    end

    def render_pygments(context, code)
      if context["content_type"] == "markdown"
        return "\n" + Albino.new(code, @lang).to_s(@options) + "\n"
      elsif context["content_type"] == "textile"
        return "<notextile>" + Albino.new(code, @lang).to_s(@options) + "</notextile>"
      else
        return Albino.new(code, @lang).to_s(@options)
      end
    end

    def render_codehighlighter(context, code)
    #The div is required because RDiscount blows ass
      <<-HTML
<div>
  <pre>
    <code class='#{@lang}'>#{h(code).strip}</code>
  </pre>
</div>
      HTML
    end
  end

end

Liquid::Template.register_tag('highlight', Jekyll::HighlightBlock)

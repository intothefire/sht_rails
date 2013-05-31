require "handlebars"
require "active_support"

module ShtRails

  module Handlebars
    def self.call(template)
      if template.locals.include?(ShtRails.action_view_key.to_s) || template.locals.include?(ShtRails.action_view_key.to_sym)
<<-SHT
  hbs_context_for_sht = Handlebars::Context.new
  partials.each do |key, value|
    hbs_context_for_sht.register_partial(key, value)
  end if defined?(partials) && partials.is_a?(Hash)

  hbs_context_for_sht.register_helper('if_type') do |context, type, compare, block|
    if type == compare
      "#{block.fn(context)}"
    end
  end

  hbs_context_for_sht.compile(#{template.source.inspect}).call(#{ShtRails.action_view_key.to_s} || {}).html_safe
SHT
      else
        "#{template.source.inspect}.html_safe"
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler(::ShtRails.template_extension.to_sym, ::ShtRails::Handlebars)
end
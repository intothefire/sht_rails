require 'tilt'

module ShtRails
  class Tilt < Tilt::Template
    def self.default_mime_type
      'application/javascript'
    end

    def prepare
      @namespace = "this.#{ShtRails.template_namespace}"
    end

    attr_reader :namespace

    def evaluate(scope, locals, &block)
      template_key = path_to_key scope
      
      js_key = template_key.inspect
      
      <<-HandlebarsTemplate
  (function() { 

  var template_html = #{data.inspect};  
  #{namespace} || (#{namespace} = {});
  #{namespace}CachedShtTemplates || (#{namespace}CachedShtTemplates = {});
  #{namespace}CachedShtTemplates[#{js_key}] = Handlebars.compile(template_html);
  
  Handlebars.registerPartial(#{js_key}, template_html)
  
  #{namespace}[#{js_key}] = function(object) {
    if (object == null){
      return #{ShtRails.template_namespace}CachedShtTemplates[#{js_key}];
    } else {
      return #{ShtRails.template_namespace}CachedShtTemplates[#{js_key}](object);
    }
  };
  }).call(this);
      HandlebarsTemplate
    end
    
    def path_to_key(scope)
      path = scope.logical_path.to_s.split('/')
      path.last.gsub!(/^_/, '')
      path.join('/')
    end
  end
end
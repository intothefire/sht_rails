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
      
      js_key = template_key.inspect.gsub('/', '.')
      
      raise js_key.to_s
      
      <<-HandlebarsTemplate
  (function() { 
  #{namespace} || (#{namespace} = {});
  #{namespace}CachedShtTemplates || (#{namespace}CachedShtTemplates = {});
  #{namespace}CachedShtTemplates[#{js_key}] = Handlebars.compile(#{data.inspect});
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
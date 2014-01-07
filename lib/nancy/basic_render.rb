require 'erb'

module Nancy
  module BasicRender
    def render(template)
      ERB.new(template).result(binding)
    end
  end
end

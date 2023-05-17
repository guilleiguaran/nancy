require "erb"

module Nancy
  module BasicRender
    def render(template)
      template = File.read(template)
      ERB.new(template).result(binding)
    end
  end
end

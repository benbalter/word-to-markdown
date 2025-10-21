module Shoulda
  module Context
    class Railtie < Rails::Railtie
      initializer "shoulda_context.autoload_macros" do
        if Rails.env.test?
          Shoulda.autoload_macros(
            Rails.root,
            File.join("vendor", "{plugins,gems}", "*")
          )
        end
      end
    end
  end
end

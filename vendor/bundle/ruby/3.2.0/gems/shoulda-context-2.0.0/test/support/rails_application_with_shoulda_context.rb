require_relative "snowglobe"

class RailsApplicationWithShouldaContext < Snowglobe::RailsApplication
  ROOT_DIRECTORY = Pathname.new("../../..").expand_path(__FILE__)

  def create
    super

    bundle.updating do
      bundle.add_gem(test_framework_gem_name, group: :test)
      bundle.add_gem("shoulda-context", path: ROOT_DIRECTORY, group: :test)
    end
  end

  def test_framework_require_path
    if TEST_FRAMEWORK == "test_unit"
      "test-unit"
    else
      "minitest/autorun"
    end
  end

  def create_gem_with_macro(module_name:, location:, macro_name:)
    fs.write_file("#{location}/shoulda_macros/macros.rb", <<~FILE)
      module #{module_name}
        def #{macro_name}
          puts "#{macro_name} is available"
        end
      end

      Shoulda::Context.configure do |config|
        config.extend(#{module_name})
      end
    FILE
  end

  private

  def test_framework_gem_name
    if TEST_FRAMEWORK == "test_unit"
      "test-unit"
    else
      "minitest"
    end
  end
end

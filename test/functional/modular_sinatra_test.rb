# PaperTrail is not compatible with sinatra 2 yet. Contributions welcome.
if Gem::Version.new(Rack.release) < Gem::Version.new("2.0.0.alpha")
  require "test_helper"
  require "sinatra/base"

  # --- Tests for modular `Sinatra::Base` style ----
  class BaseApp < Sinatra::Base
    configs = YAML.load_file(File.expand_path("../../dummy/config/database.yml", __FILE__))
    ActiveRecord::Base.configurations = configs
    ActiveRecord::Base.establish_connection(:test)
    register PaperTrail::Sinatra

    get "/test" do
      Widget.create!(name: "foo")
      "Hello"
    end

    def current_user
      @current_user ||= OpenStruct.new(id: "foobar")
    end
  end

  class ModularSinatraTest < ActionDispatch::IntegrationTest
    include Rack::Test::Methods

    def app
      @app ||= BaseApp
    end

    test "baseline" do
      assert_nil Widget.create.versions.first.whodunnit
    end

    context "`PaperTrail::Sinatra` in a `Sinatra::Base` application" do
      should "sets the `user_for_paper_trail` from the `current_user` method" do
        get "/test"
        assert_equal "Hello", last_response.body
        widget = Widget.last
        assert_not_nil widget
        assert_equal "foo", widget.name
        assert_equal 1, widget.versions.size
        assert_equal "foobar", widget.versions.first.whodunnit
      end
    end
  end
end

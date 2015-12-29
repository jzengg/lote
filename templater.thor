class Test < Thor
  include Thor::Actions

  desc "install APP_NAME", "install one of the available apps"

    def install(name)
      puts name

    end

end

Test.start

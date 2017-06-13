if defined?(Motion::Project::App)
  # iOS or Android project.
  dirname = File.dirname(__FILE__)
  case Motion::Project::App.template
    when :android
      require "#{dirname}/android.rb"
    when :ios, :tvos, :osx, :'ios-extension'
      require "#{dirname}/cocoa.rb"
    else
      raise "Project template #{Motion::Project::App.template} not supported by Flow"
  end
else
  # Flow project.
  def invoke_rake(platform, task)
    trace = Rake.application.options.trace == true

    template = platform.to_s == 'android' ? 'android' : 'cocoa'
    system "template=#{platform} rake -r \"#{File.dirname(__FILE__)}/#{template}.rb\" -f \"config/#{platform}.rb\" \"#{task}\" #{trace ? '--trace' : ''}" or exit 1
  end
  namespace 'ios' do
    desc "Create an .ipa archive"
    task "archive" do
      invoke_rake 'ios', 'archive'
    end
    desc "Create an .ipa archive for distribution (AppStore)"
    task "archive:distribution" do
      invoke_rake 'ios', 'archive:distribution'
    end
    desc "Build everything"
    task "build" do
      invoke_rake 'ios', 'build'
    end
    desc "Build the device version"
    task "build:device" do
      invoke_rake 'ios', 'build:device'
    end
    desc "Build the simulator version"
    task "build:simulator" do
      invoke_rake 'ios', 'build:simulator'
    end
    desc "Clear local build objects"
    task "clean" do
      invoke_rake 'ios', 'clean'
    end
    desc "Clean all build objects"
    task "clean:all" do
      invoke_rake 'ios', 'clean:all'
    end
    desc "Show project config"
    task "config" do
      invoke_rake 'ios', 'config'
    end
    desc "Same as crashlog:simulator"
    task "crashlog" do
      invoke_rake 'ios', 'crashlog'
    end
    desc "Retrieve and symbolicate crash logs generated by the app on the device, and open the latest generated one"
    task "crashlog:device" do
      invoke_rake 'ios', 'crashlog:device'
    end
    desc "Open the latest crash report generated by the app in the simulator"
    task "crashlog:simulator" do
      invoke_rake 'ios', 'crashlog:simulator'
    end
    desc "Generate ctags"
    task "ctags" do
      invoke_rake 'ios', 'ctags'
    end
    desc "Build the project, then run the simulator"
    task "default" do
      invoke_rake 'ios', 'default'
    end
    desc "Deploy on the device"
    task "device" do
      invoke_rake 'ios', 'device'
    end
    desc "Same as profile:simulator"
    task "profile" do
      invoke_rake 'ios', 'profile'
    end
    desc "Run a build on the device through Instruments"
    task "profile:device" do
      invoke_rake 'ios', 'profile:device'
    end
    desc "List all built-in device Instruments templates"
    task "profile:device:templates" do
      invoke_rake 'ios', 'profile:device:templates'
    end
    desc "Run a build on the simulator through Instruments"
    task "profile:simulator" do
      invoke_rake 'ios', 'profile:simulator'
    end
    desc "List all built-in Simulator Instruments templates"
    task "profile:simulator:templates" do
      invoke_rake 'ios', 'profile:simulator:templates'
    end
    desc "Run the simulator"
    task "simulator" do
      invoke_rake 'ios', 'simulator'
    end
    desc "Same as 'spec:simulator'"
    task "spec" do
      invoke_rake 'ios', 'spec'
    end
    desc "Run the test/spec suite on the device"
    task "spec:device" do
      invoke_rake 'ios', 'spec:device'
    end
    desc "Run the test/spec suite on the simulator"
    task "spec:simulator" do
      invoke_rake 'ios', 'spec:simulator'
    end
    desc "Create a .a static library"
    task "static" do
      invoke_rake 'ios', 'static'
    end
    desc "Same as 'watch:simulator'"
    task "watch" do
      invoke_rake 'ios', 'watch'
    end
    desc "Run the Watch application on the simulator"
    task "watch:simulator" do
      invoke_rake 'ios', 'watch:simulator'
    end
  end
  namespace 'android' do
    desc "Create an application package file (.apk)"
    task "build" do
      invoke_rake 'android', 'build'
    end
    desc "Clear local build objects"
    task "clean" do
      invoke_rake 'android', 'clean'
    end
    desc "Clean all build objects"
    task "clean:all" do
      invoke_rake 'android', 'clean:all'
    end
    desc "Show project config"
    task "config" do
      invoke_rake 'android', 'config'
    end
    desc "Generate ctags"
    task "ctags" do
      invoke_rake 'android', 'ctags'
    end
    desc "Same as 'rake emulator'"
    task "default" do
      invoke_rake 'android', 'default'
    end
    desc "Build the app then run it in the device"
    task "device" do
      invoke_rake 'android', 'device'
    end
    desc "Install the app in the device"
    task "device:install" do
      invoke_rake 'android', 'device:install'
    end
    desc "Start the app's main intent in the device"
    task "device:start" do
      invoke_rake 'android', 'device:start'
    end
    desc "Build the app then run it in the emulator"
    task "emulator" do
      invoke_rake 'android', 'emulator'
    end
    desc "Install the app in the emulator"
    task "emulator:install" do
      invoke_rake 'android', 'emulator:install'
    end
    desc "Start the app's main intent in the emulator"
    task "emulator:start" do
      invoke_rake 'android', 'emulator:start'
    end
    desc "Create an application package file (.apk) for release (Google Play)"
    task "release" do
      invoke_rake 'android', 'release'
    end
    desc "Same as 'spec:emulator'"
    task "spec" do
      invoke_rake 'android', 'spec'
    end
    desc "Run the test/spec suite on the device"
    task "spec:device" do
      invoke_rake 'android', 'spec:device'
    end
    desc "Run the test/spec suite on the emulator"
    task "spec:emulator" do
      invoke_rake 'android', 'spec:emulator'
    end
  end
  namespace 'osx' do
    desc "Build the project for development"
    task 'build' do
      invoke_rake 'osx', 'build'
    end
    desc "Build the project for release"
    task 'build:release' do
      invoke_rake 'osx', 'build:release'
    end
    desc "Run the project"
    task 'run' do
      invoke_rake 'osx', 'run'
    end
    desc "Run the test/spec suite"
    task 'spec' do
      invoke_rake 'osx', 'spec'
    end
    desc "Create a .pkg archive"
    task 'archive' do
      invoke_rake 'osx', 'archive'
    end
    desc "Create a .pkg archive for distribution (AppStore)"
    task 'archive:distribution' do
      invoke_rake 'osx', 'archive:distribution'
    end
    desc "Create a .a static library"
    task 'static' do
      invoke_rake 'osx', 'static'
    end
    desc "Open the latest crash report generated for the app"
    task "crashlog" do
      invoke_rake 'osx', 'crashlog'
    end
    desc "Clear local build objects"
    task "clean" do
      invoke_rake 'osx', 'clean'
    end
  end
  desc "Start a combined iOS/Android REPL"
  task "super_repl" do
    require "readline"

    cmd = %w{ rake }
    ios_cmd = cmd + ['ios:simulator']
    android_cmd = cmd + ['android:emulator:start']

    if ENV.fetch("skip_build", nil)
      ios_cmd << 'skip_build=1'
      android_cmd << 'skip_build=1'
    end

    ios_io = IO.popen(ios_cmd.join(' '), 'w')
    android_io = IO.popen(android_cmd.join(' '), 'w')

    while expr = Readline.readline("> ", true)
      ios_io.puts expr
      android_io.puts expr
      sleep 0.2
    end
  end
end

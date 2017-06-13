# -*- coding: utf-8 -*-

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake android:config' to see complete project settings.
  app.name = 'Registration Form'
  app.archs << 'x86'
  app.api_version = '22'
end

# -*- coding: utf-8 -*-

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake ios:config' to see complete project settings.
  app.name = 'Registration Form'
  app.identifier = 'com.scratchworkdevelopment.registrationform'
  app.codesign_certificate = 'iPhone Developer: Amirali Rajan'
  app.provisioning_profile = './profiles/Development_Wildcard.mobileprovision'
  app.interface_orientations = [:portrait]

  # app.development do
  #   app.codesign_certificate = MotionProvisioning.certificate(
  #     type: :development,
  #     platform: :ios)

  #   app.provisioning_profile = MotionProvisioning.profile(
  #     bundle_identifier: app.identifier,
  #     app_name: app.name,
  #     platform: :ios,
  #     type: :development)
  # end
end

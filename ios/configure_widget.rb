require 'xcodeproj'

project_path = '/Volumes/Lexar SL300/streaks/ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

widget_target = project.targets.find { |t| t.name == 'RunnerWidget' }

if widget_target.nil?
  puts "Creating RunnerWidget target..."
  widget_target = project.new_target(:app_extension, 'RunnerWidget', :ios, '14.0', nil, :swift)
  widget_target.product_type = 'com.apple.product-type.app-extension'
else
  puts "RunnerWidget target already exists. Configuring..."
end

runner_group = project.main_group
widget_group = runner_group.find_subpath('RunnerWidget', true)
widget_group.clear

files = [
  'ios/RunnerWidget/RunnerWidget.swift',
  'ios/RunnerWidget/RunnerWidgetBundle.swift',
  'ios/RunnerWidget/Info.plist',
  'ios/RunnerWidget/RunnerWidget.entitlements'
]

file_references = []
files.each do |f|
  relpath = f.sub('ios/', '')
  ref = widget_group.new_file(relpath)
  file_references << ref
end

sources_build_phase = widget_target.source_build_phase
sources_build_phase.clear
file_references.each do |ref|
  if ref.path.end_with?('.swift')
    sources_build_phase.add_file_reference(ref)
  end
end

widget_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = 'RunnerWidget'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.streaks.runnerwidget'
  config.build_settings['PRODUCT_BUNDLE_PACKAGE_TYPE'] = 'XPC!'
  config.build_settings['INFOPLIST_FILE'] = 'RunnerWidget/Info.plist'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'RunnerWidget/RunnerWidget.entitlements'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
  config.build_settings['SKIP_INSTALL'] = 'YES'
end

# Set project-level deployment target
project.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
end

runner_target = project.targets.find { |t| t.name == 'Runner' }
if runner_target
  puts "Configuring Runner target..."
  
  runner_app_group = runner_group.find_subpath('Runner', false)
  if runner_app_group
    ent_ref = runner_app_group.find_file_by_path('Runner.entitlements')
    if ent_ref.nil?
      ent_ref = runner_app_group.new_file('Runner.entitlements')
    end
  end
  
  runner_target.build_configurations.each do |config|
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  end
end

runner_tests_target = project.targets.find { |t| t.name == 'RunnerTests' }
if runner_tests_target
  puts "Configuring RunnerTests target..."
  runner_tests_target.build_configurations.each do |config|
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  end
end


unless runner_target.dependencies.any? { |dep| dep.target == widget_target }
  puts "Adding target dependency: RunnerWidget -> Runner"
  runner_target.add_dependency(widget_target)
end

embed_phase = runner_target.copy_files_build_phases.find { |phase| phase.name == 'Embed App Extensions' || phase.symbol_dst_subfolder_spec == :plug_ins }
if embed_phase.nil?
  embed_phase = runner_target.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
end

embed_phase.clear
embed_phase.add_file_reference(widget_target.product_reference)

# Reorder build phases to prevent Xcode 15 dependency cycles
# Copy App Extensions MUST run BEFORE Thin Binary / Embed Pods Frameworks scripts
puts "Reordering build phases for Runner target to avoid dependency cycles..."
runner_target.build_phases.delete(embed_phase)
thin_binary_idx = runner_target.build_phases.index { |bp| bp.respond_to?(:name) && bp.name == 'Thin Binary' || bp.display_name == 'Thin Binary' }
if thin_binary_idx
  runner_target.build_phases.insert(thin_binary_idx, embed_phase)
else
  # Fallback: insert before the last elements (e.g. index 6)
  runner_target.build_phases.insert(6, embed_phase)
end

project.save
puts "Xcode project configured successfully!"

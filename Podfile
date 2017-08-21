source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.1'
use_frameworks!

target 'Eggy' do
    
    pod 'Armchair', '>= 0.3'
    
    #Add the following in order to automatically set debug flags for armchair in debug builds
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if target.name == 'Armchair'
                target.build_configurations.each do |config|
                    if config.name == 'Debug'
                        config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDebug'
                        else
                        config.build_settings['OTHER_SWIFT_FLAGS'] = ''
                    end
                end
            end
        end
    end

end

target 'EggyTests' do

end

target 'EggyUITests' do

end


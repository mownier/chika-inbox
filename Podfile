source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/mownier/chika-podspecs.git'
source 'https://github.com/mownier/podspecs.git'
platform :ios, '11.0'
use_frameworks!

target 'ChikaInbox' do
    
    pod 'DateTools'
    
    pod 'ChikaSignIn'
    pod 'ChikaRegistrar'
    
    pod 'ChikaFirebase/Auth:SignOut'
    
    pod 'ChikaFirebase/Query:Inbox'
    pod 'ChikaFirebase/Query:UnreadChatMessageCount'
    
    pod 'ChikaFirebase/Writer:OnlinePresenceSwitcher'
    pod 'ChikaFirebase/Writer:OfflinePresenceSwitcher'
    
    pod 'ChikaFirebase/Listener:Presence'
    pod 'ChikaFirebase/Listener:TypingStatus'
    pod 'ChikaFirebase/Listener:AddedIntoChat'
    pod 'ChikaFirebase/Listener:ChatTitleUpdate'
    pod 'ChikaFirebase/Listener:RecentChatMessage'
    pod 'ChikaFirebase/Listener:ChatParticipantPresence'
    
    pod 'ChikaUI'
    pod 'ChikaAssets'
    
    target 'ChikaInboxTests' do
        inherit! :search_paths
        # Pods for testing
    end
    
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
        if config.name == 'Release'
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        end
    end
end

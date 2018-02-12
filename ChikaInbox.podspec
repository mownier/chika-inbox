Pod::Spec.new do |s|
  s.name     = 'ChikaInbox'
  s.version  = '0.0.1'
  s.summary  = 'Inbox Module for Chika'
  s.platform = :ios, '11.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/mownier/chika-inbox'
  s.author   = { 'Mounir Ybanez' => 'rinuom91@gmail.com' }
  s.source   = { :git => 'https://github.com/mownier/chika-inbox.git', :tag => s.version.to_s }
  s.source_files = 'ChikaInbox/Source/*.swift'
  s.resources = ['ChikaInbox/Source/Inbox.storyboard']
  s.requires_arc = true

  s.dependency 'DateTools'
  
  s.dependency 'ChikaFirebase/Query:Inbox'
  s.dependency 'ChikaFirebase/Query:UnreadChatMessageCount'
  
  s.dependency 'ChikaFirebase/Listener:Presence'
  s.dependency 'ChikaFirebase/Listener:TypingStatus'
  s.dependency 'ChikaFirebase/Listener:AddedIntoChat'
  s.dependency 'ChikaFirebase/Listener:ChatTitleUpdate'
  s.dependency 'ChikaFirebase/Listener:RecentChatMessage'
  s.dependency 'ChikaFirebase/Listener:ChatParticipantPresence'

  s.dependency 'ChikaUI'
  s.dependency 'ChikaAssets'
end

//
//  Factory.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/6/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaCore
import ChikaFirebase
import FirebaseCommunity

public final class Factory {
    
    var meID: String?
    var theme: Theme?
    var query: (() -> ChikaCore.InboxQuery)?
    var onSelect: ((Chat) -> Void)?
    var unreadChatCountTracker: ((Int) -> Void)?
    
    public init() {
        self.meID = FirebaseCommunity.Auth.auth().currentUser?.uid ?? ""
        self.theme = Theme()
        self.query = { InboxQuery() }
    }
    
    public func withMeID(_ id: String) -> Factory {
        self.meID = id
        return self
    }
    
    public func withTheme(_ theme: Theme) -> Factory {
        self.theme = theme
        return self
    }
    
    public func withQuery(_ query: @escaping () -> ChikaCore.InboxQuery) -> Factory {
        self.query = query
        return self
    }
    
    public func withUnreadChatCountTracker(_ tracker: @escaping (Int) -> Void) -> Factory {
        self.unreadChatCountTracker = tracker
        return self
    }
    
    public func onSelect(_ block: @escaping (Chat) -> Void) -> Factory {
        self.onSelect = block
        return self
    }
    
    public func build() -> Scene {
        defer {
            meID = nil
            theme = nil
            query = nil
            onSelect = nil
            unreadChatCountTracker = nil
        }
        
        let data = DataProvider(meID: meID ?? "")
        let bundle = Bundle(for: Factory.self)
        let storyboard = UIStoryboard(name: "Inbox", bundle: bundle)
        let scene = storyboard.instantiateInitialViewController() as! Scene
        scene.data = data
        scene.theme = theme
        scene.query = query
        scene.onSelect = onSelect
        scene.operation = InboxQueryOperation()
        scene.unreadChatCountTracker = unreadChatCountTracker
        
        scene.recentChatMessageListener = RecentChatMessageListener()
        scene.recentChatMessageListenerOperator = RecentChatMessageListenerOperation()
        
        scene.typingStatusListener = TypingStatusListener()
        scene.typingStatusListenerOperator = TypingStatusListenerOperation()
        
        scene.chatTitleUpdateListener = ChatTitleUpdateListener()
        scene.chatTitleUpdateListenerOperator = ChatTitleUpdateListenerOperation()
        
        scene.chatParticipantPresenceListener = ChatParticipantPresenceListener()
        scene.chatParticipantPresenceListenerOperator = ChatParticipantPresenceListenerOperation()
        
        scene.addedIntoChatListener = AddedIntoChatListener()
        scene.addedIntoChatListenerOperator = AddedIntoChatListenerOperation()
        
        scene.unreadCountQuery = UnreadChatMessageCountQuery()
        scene.unreadCountQueryOperator = UnreadChatMessageCountQueryOperation()
        
        return scene
    }
    
}

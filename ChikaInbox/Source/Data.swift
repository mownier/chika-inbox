//
//  Data.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/6/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore

protocol Data {
    
    var itemCount: Int { get }
    var unreadChatCount: Int { get }
    
    func item(at index: Int) -> Item?
    func item(for chat: Chat) -> Item?
    func append(_ chats: [Chat])
    func removeAll()
    
    @discardableResult
    func increaseUnreadMessageCount(by count: UInt, for chat: Chat) -> Int?
    
    @discardableResult
    func update(with chat: Chat) -> UpdateIndexResult?
    
    @discardableResult
    func updateUnreadMessageCount(for item: Item) -> Int?
    
    @discardableResult
    func updatePresenceStatus(with object: ChatParticipantPresenceListenerObject) -> Int?
    
    @discardableResult
    func updateTypingStatus(with object: TypingStatusListenerObject) -> Int?
    
    @discardableResult
    func updateTitle(with object: ChatTitleUpdateListenerObject) -> Int?
}

struct Item {
    
    var chat: Chat
    var isActive: Bool
    var typingPersons: [Person: Bool]
    var unreadMessageCount: UInt
    
    var typingText: String {
        guard !typingPersons.isEmpty else {
            return ""
        }
        
        guard typingPersons.count < 5 else {
            return "There are people typing..."
        }
        
        return typingPersons.flatMap({ $0.key.displayName }).joined(separator: ",").appending(typingPersons.count == 1 ? " is" : " are").appending(" typing...")
    }
    
    init(chat: Chat) {
        self.chat = chat
        self.isActive = false
        self.typingPersons = [:]
        self.unreadMessageCount = 0
    }
}

struct UpdateIndexResult {
    
    fileprivate(set) var old: Int = 0
    fileprivate(set) var new: Int = 0
}

class DataProvider: Data {
    
    var itemCount: Int {
        return items.count
    }
    
    var unreadChatCount: Int {
        return items.reduce(into: 0) { result, item in
            if item.unreadMessageCount > 0 {
                result += 1
            }
        }
    }
    
    var meID: ID
    var items: [Item]
    
    init(meID: String) {
        self.items = []
        self.meID = ID(meID)
    }
    
    func item(at index: Int) -> Item? {
        guard index >= 0, index < items.count else {
            return nil
        }
        
        return items[index]
    }
    
    func item(for chat: Chat) -> Item? {
        guard let index = items.index(where: { $0.chat.id == chat.id }) else {
            return nil
        }
        
        return items[index]
    }
    
    func append(_ chats: [Chat]) {
        items.append(contentsOf: chats.map({ Item(chat: $0) }))
    }
    
    func removeAll() {
        items.removeAll()
    }
    
    func increaseUnreadMessageCount(by count: UInt, for chat: Chat) -> Int? {
        guard let index = items.index(where: { $0.chat.id == chat.id }) else {
            return nil
        }
        
        items[index].unreadMessageCount += count
        return index
    }
    
    func update(with chat: Chat) -> UpdateIndexResult? {
        guard !items.isEmpty else {
            return nil
        }
        
        var item: Item
        var isNewer: Bool = true
        var indexResult = UpdateIndexResult()
        var isMessageCountIncremented: Bool = true
        
        if let index = items.index(where: { $0.chat.id == chat.id }), let newest = items.first?.chat {
            isNewer = chat.recent.date.timeIntervalSince1970 > newest.recent.date.timeIntervalSince1970
            indexResult.old = index
            
            if isNewer {
                item = items.remove(at: index)
                indexResult.new = 0
                
            } else {
                item = items[index]
                indexResult.new = index
            }
            
            isMessageCountIncremented = item.chat.recent.id != chat.recent.id
            item.chat.recent = chat.recent
        
        } else {
            item = Item(chat: chat)
        }
        
        if item.chat.recent.author.id != meID && isMessageCountIncremented {
            item.unreadMessageCount += 1
        }
        
        if isNewer {
            items.insert(item, at: indexResult.new)
            
        } else {
            items[indexResult.old] = item
        }
        
        return indexResult
    }
    
    func updateUnreadMessageCount(for item: Item) -> Int? {
        guard let index = items.index(where: { $0.chat.id == item.chat.id }) else {
            return nil
        }
        
        items[index].unreadMessageCount = item.unreadMessageCount
        return index
    }
    
    func updatePresenceStatus(with object: ChatParticipantPresenceListenerObject) -> Int? {
        guard let index = items.index(where: { $0.chat.id == object.chatID }) else {
            return nil
        }
        
        items[index].isActive = object.presence.isActive
        return index
    }
    
    func updateTypingStatus(with object: TypingStatusListenerObject) -> Int? {
        guard let index = items.index(where: { $0.chat.id == object.chatID }) else {
            return nil
        }
        
        switch object.status {
        case .typing:
            if items[index].typingPersons.count <= 5 {
                items[index].typingPersons[object.person] = true
            }
        
        case .notTyping:
            items[index].typingPersons.removeValue(forKey: object.person)
        }
        
        return index
    }
    
    func updateTitle(with object: ChatTitleUpdateListenerObject) -> Int? {
        guard let index = items.index(where: { $0.chat.id == object.chatID }) else {
            return nil
        }
        
        items[index].chat.title = object.title
        return index
    }
    
}

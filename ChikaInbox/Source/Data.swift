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
    func append(_ chats: [Chat])
    func update(_ chat: Chat) -> UpdateResult
    func updateMessageCount(for item: Item)
    func updateActiveStatus(for participantID: String, isActive: Bool) -> [Int]
    func updateTypingStatus(for chatID: String, participantID: String, isTyping: Bool) -> Int?
    func updateTitle(for chatID: String, title: String) -> Int?
    func removeAll()
    func item(for chat: Chat) -> Item?
    func tryToUpdateActiveStatus(for chat: Chat)
}

enum UpdateResult {
    
    case new(Bool)
    case existing(Bool)
    
    var isYours: Bool {
        switch self {
        case .new(let isYours),
             .existing(let isYours):
            return isYours
        }
    }
}

struct Item {
    
    var chat: Chat
    var isSomeoneOnline: Bool
    var typingText: String
    var unreadMessageCount: UInt
    var active: [String: Bool]
    var typing: [String: String]
    
    init(chat: Chat) {
        self.chat = chat
        self.isSomeoneOnline = false
        self.unreadMessageCount = 0
        self.typingText = ""
        self.active = [:]
        self.typing = [:]
    }
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
    
    func append(_ chats: [Chat]) {
        items.append(contentsOf: chats.map({ Item(chat: $0) }))
    }
    
    func update(_ newChat: Chat) -> UpdateResult {
        return .new(false)
    }
    
    func updateMessageCount(for item: Item) {
    }
    
    func updateActiveStatus(for participantID: String, isActive: Bool) -> [Int] {
        return []
    }
    
    func updateTypingStatus(for chatID: String, participantID: String, isTyping: Bool) -> Int? {
        return nil
    }
    
    func updateTitle(for chatID: String, title: String) -> Int? {
        return nil
    }
    
    func removeAll() {
        items.removeAll()
    }
    
    func item(for chat: Chat) -> Item? {
        return nil
    }
    
    func tryToUpdateActiveStatus(for chat: Chat) {

    }
    
}

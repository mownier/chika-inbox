//
//  Scene.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/6/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaCore
import ChikaFirebase

public final class Scene: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: Data!
    var theme: Theme!
    var query: (() -> ChikaCore.InboxQuery)!
    var operation: InboxQueryOperator!
    
    var onSelect: ((Chat) -> Void)?
    var unreadChatCountTracker: ((Int) -> Void)?
    
    var recentChatMessageListener: ChikaCore.RecentChatMessageListener!
    var recentChatMessageListenerOperator: RecentChatMessageListenerOperator!
    
    var typingStatusListener: ChikaCore.TypingStatusListener!
    var typingStatusListenerOperator: TypingStatusListenerOperator!
    
    var chatTitleUpdateListener: ChikaCore.ChatTitleUpdateListener!
    var chatTitleUpdateListenerOperator: ChatTitleUpdateListenerOperator!
    
    var chatParticipantPresenceListener: ChikaCore.ChatParticipantPresenceListener!
    var chatParticipantPresenceListenerOperator: ChikaCore.ChatParticipantPresenceListenerOperator!
    
    var addedIntoChatListener: ChikaCore.AddedIntoChatListener!
    var addedIntoChatListenerOperator: ChikaCore.AddedIntoChatListenerOperator!
    
    var unreadCountQuery: ChikaCore.UnreadChatMessageCountQuery!
    var unreadCountQueryOperator: ChikaCore.UnreadChatMessageCountQueryOperator!

    deinit {
        dispose()
    }
    
    public func dispose() {
        data = nil
        theme = nil
        query = nil
        operation = nil
        unreadChatCountTracker = nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard query != nil else {
            return
        }
        
        let _ = addedIntoChatListenerOperator.withCallback(onAddedIntoChat).startListening(using: addedIntoChatListener)
        let _ = operation.withCompletion(completion).getInbox(using: query())
    }
    
    private func completion(_ result: Result<[Chat]>) {
        switch result {
        case .ok(let chats):
            for chat in chats {
                listen(on: chat)
                getUnreadCount(for: chat)
            }
            
            data.append(chats)
            tableView.reloadData()
            
        default:
            break
        }
    }
    
    private func getUnreadCount(for chat: Chat) {
        let completion: (Result<UInt>) -> Void = { [weak self] result in
            guard let this = self else {
                return
            }
            
            switch result {
            case .ok(let count):
                let index = this.data.increaseUnreadMessageCount(by: count, for: chat)
                this.updateCell(at: index)
                
                print(chat.id, this.data.item(at: index!)!.unreadMessageCount)
            case .err:
                break
            }
        }
        
        unreadCountQueryOperator.withChatID(chat.id).withCompletion(completion).getUnreadChatMessageCount(using: unreadCountQuery)
    }
    
    private func listen(on chat: Chat) {
        let _ = typingStatusListenerOperator.withChatID(chat.id).withCallback(onTypingStatusChanged).startListening(using: typingStatusListener)
        let _ = chatTitleUpdateListenerOperator.withChatID(chat.id).withCallback(onChatTitleUpdated).startListening(using: chatTitleUpdateListener)
        let _ = recentChatMessageListenerOperator.withChatID(chat.id).withCallback(onRecentChatMessageReceived).startListening(using: recentChatMessageListener)
        let _ = chatParticipantPresenceListenerOperator.withChatID(chat.id).withCallback(onChatParticipantPresenceChanged).startListening(using: chatParticipantPresenceListener)
    }
    
    private func onTypingStatusChanged(_ result: Result<TypingStatusListenerObject>) {
        switch result {
        case .ok(let object):
            let row = data.updateTypingStatus(with: object)
            updateCell(at: row)
            
        case .err:
            break
        }
    }
    
    private func onChatTitleUpdated(_ result: Result<ChatTitleUpdateListenerObject>) {
        switch result {
        case .ok(let object):
            let row = data.updateTitle(with: object)
            updateCell(at: row)
            
        case .err:
            break
        }
    }
    
    private func onRecentChatMessageReceived(_ result: Result<Chat>) {
        switch result {
        case .ok(let chat):
            let oldCount = data.itemCount
            let indexResult = data.update(with: chat)
            let newCount = data.itemCount
            
            if newCount == oldCount {
                let moved = moveCell(with: indexResult)
                updateCell(at: moved ? indexResult?.new : indexResult?.old)
            
            } else if newCount > oldCount {
                insertCell(with: indexResult)
            }
            
            unreadChatCountTracker?(data.unreadChatCount)
            
        case .err:
            break
        }
    }
    
    private func onChatParticipantPresenceChanged(_ result: Result<ChatParticipantPresenceListenerObject>) {
        switch result {
        case .ok(let object):
            let row = data.updatePresenceStatus(with: object)
            updateCell(at: row)
            
        case .err:
            break
        }
    }
    
    private func onAddedIntoChat(_ result: Result<Chat>) {
        switch result {
        case .ok(let chat):
            listen(on: chat)
            getUnreadCount(for: chat)
        
        case .err:
            break
        }
    }
    
    private func updateCell(at row: Int?) {
        guard let row = row else {
            return
        }
        
        let reloadedRows = [IndexPath(row: row, section: 0)]
        tableView.beginUpdates()
        tableView.reloadRows(at: reloadedRows, with: .none)
        tableView.endUpdates()
    }
    
    private func insertCell(with indexResult: UpdateIndexResult?) {
        guard let index = indexResult else {
            return
        }
        
        let insertedRows = [IndexPath(row: index.new, section: 0)]
        tableView.beginUpdates()
        tableView.insertRows(at: insertedRows, with: .top)
        tableView.endUpdates()
    }
    
    @discardableResult
    private func moveCell(with indexResult: UpdateIndexResult?) -> Bool {
        guard let index = indexResult, index.old != index.new else {
            return false
        }
        
        let old = IndexPath(row: index.old, section: 0)
        let new = IndexPath(row: index.new, section: 0)
        tableView.beginUpdates()
        tableView.moveRow(at: old, to: new)
        tableView.endUpdates()
        return true
    }
    
}

extension Scene: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.itemCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        let item = data.item(at: indexPath.row)
        cell.layout(withItem: item)
        return cell
    }
    
}

extension Scene: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = data.item(at: indexPath.row) else {
            return
        }
        
        onSelect?(item.chat)
    }
    
}

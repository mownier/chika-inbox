//
//  Scene.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/6/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaCore

public final class Scene: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: Data!
    var theme: Theme!
    var query: (() -> ChikaCore.InboxQuery)!
    var operation: InboxQueryOperator!
    
    var onSelect: ((Chat) -> Void)?

    deinit {
        dispose()
    }
    
    public func dispose() {
        data = nil
        theme = nil
        query = nil
        operation = nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard query != nil else {
            return
        }
        
        let _ = operation.withCompletion(completion).getInbox(using: query())
    }
    
    private func completion(_ result: Result<[Chat]>) {
        switch result {
        case .ok(let chats):
            data.append(chats)
            tableView.reloadData()
            
        default:
            break
        }
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

//
//  Cell.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/6/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaUI
import DateTools

class Cell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var presenceStatusView: UIView!
    
    @IBOutlet weak var unreadCountLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTrailingConstraint: NSLayoutConstraint!
    
    var typingView: TypingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        typingView = TypingView(frame: .zero)
        contentView.addSubview(typingView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.lightGray.cgColor
        avatarView.layer.cornerRadius = avatarView.bounds.width / 2
        avatarView.layer.masksToBounds = true
        
        presenceStatusView.layer.cornerRadius = presenceStatusView.bounds.width / 2
        presenceStatusView.layer.masksToBounds = true
        contentView.bringSubview(toFront: presenceStatusView)
        
        unreadCountLabel.layer.cornerRadius = unreadCountLabel.bounds.width / 2
        unreadCountLabel.layer.masksToBounds = true
        
        typingView.frame = avatarView.frame
        typingView.layer.cornerRadius = avatarView.layer.cornerRadius
        typingView.layer.masksToBounds = true
    }
    
    func layout(withItem item: Item?) {
        typingView.stopAnimating()
        
        if item != nil {
            if item!.typingText.isEmpty {
                timeLabel.text = (item!.chat.recent.date as NSDate).timeAgoSinceNow()?.lowercased()
                
            } else {
                typingView.startAnimating()
                timeLabel.text = item!.typingText
            }
            
        } else {
            timeLabel.text = ""
        }
        
        titleLabel.text = item?.chat.title
        avatarView.image = #imageLiteral(resourceName: "avatar")
        messageLabel.text = item?.chat.recent.content
        
        if let count = item?.unreadMessageCount, count > 0 {
            titleLabelTrailingConstraint.constant = 8
            unreadCountLabelWidthConstraint.constant = unreadCountLabel.bounds.height
            unreadCountLabel.text = "\(count)"
            
        } else {
            titleLabelTrailingConstraint.constant = 0
            unreadCountLabelWidthConstraint.constant = 0
            unreadCountLabel.text = ""
        }
        
        presenceStatusView.isHidden = item == nil ? true : !item!.isActive
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}


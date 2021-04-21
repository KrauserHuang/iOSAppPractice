//
//  SongTableViewCell.swift
//  iOSAppPractice
//
//  Created by Tai Chin Huang on 2021/4/14.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    var nameLabel = UILabel(frame: CGRect(x: 10, y: 15, width: 400, height: 20))
    
    // Initializes a table cell with a style and a reuse identifier and returns it to the caller
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
    }
    // 在init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)時因為繼承UITableViewCell而需要將
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

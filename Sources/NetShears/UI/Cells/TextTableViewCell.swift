//
//  TextTableViewCell.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/6/21.
//
//

import UIKit

final class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: NSTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

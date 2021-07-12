//
//  ActionableTableViewCell.swift
//  NetShears
//
//  Created by Mehdi Mirzaie on 6/6/21.
//
//

import UIKit

final class ActionableTableViewCell: UITableViewCell {

    @IBOutlet weak var labelAction: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

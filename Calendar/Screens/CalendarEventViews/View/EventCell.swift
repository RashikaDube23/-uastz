//
//  EventCell.swift
//  Calendar
//
//  Created by Admin on 11/06/24.
//

import UIKit

class EventCell: UITableViewCell {

    // MARK: - IBOutlets

    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
   
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}

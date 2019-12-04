//
//  CurrencyCell.swift
//  paypay
//
//  Created by Thushara Wijekoon on 12/4/19.
//  Copyright © 2019 Thushara Wijekoon. All rights reserved.
//

import UIKit

class CurrencyCell : UITableViewCell {

    @IBOutlet weak var lblTotalVal: UILabel!
    @IBOutlet weak var lblOneVal: UILabel!
//    @IBOutlet weak var lblDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
}

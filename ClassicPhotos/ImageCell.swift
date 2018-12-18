//
//  ImageCell.swift
//  ClassicPhotos
//
//  Created by van.tien.tu on 12/18/18.
//  Copyright © 2018 TuanAnh. All rights reserved.
//

import UIKit

protocol ImageCellDelegate: class {
    func startDownloadAt(_ cell: ImageCell)
}

class ImageCell: UITableViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var startDownLoadButton: UIButton!
    
    weak var delegate: ImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.progressLabel.text = nil
        self.myImageView.image = nil
        self.startDownLoadButton.setTitle("Start", for: .normal)
    }
    
    private func setupView() {
        self.progressLabel.layer.cornerRadius = 20
        self.progressLabel.layer.masksToBounds = true
    }
    
    @IBAction func startDownloadAction(_ sender: Any) {
        self.delegate?.startDownloadAt(self)
    }
}

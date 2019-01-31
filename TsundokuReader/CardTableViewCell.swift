//
//  CardTableViewCell.swift
//  TsundokuReader
//
//  Created by Ryuichi Sakagami on 2019/01/30.
//  Copyright © 2019 Ryuichi Sakagami. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

let NO_IMG = UIImage(named: "no_image")

class CardTableViewCell: UITableViewCell {

    var id: String!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    let dateFormatter = DateFormatter()
    var screenWidth: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.mainView.backgroundColor = UIColor.white
        self.mainView.layer.cornerRadius = 10.0
        self.mainView.layer.masksToBounds = true
        self.dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        self.title.font = UIFont.boldSystemFont(ofSize: 20)
        self.createdAt.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.screenWidth = UIScreen.main.bounds.width
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setProps(props: Tsundoku) {
        self.setTitle(title: props.title)
        self.setCreatedAt(createdAt: props.createdAt)
        self.setThumbNail(thumbNail: props.thumbNail)
        self.setId(id: props.id)
    }
    
    private func setId(id: String) {
        self.id = id
    }
    
    private func setTitle(title: String?) {
        self.title.text = title ??  "タイトルを取得できませんでした。"
    }
    
    private func setCreatedAt(createdAt: Date) {
        self.createdAt.text = dateFormatter.string(from: createdAt)
    }
    
    private func setThumbNail(thumbNail: UIImage?) {
        let thumbSize = CGSize(
            width: screenWidth!,
            height: screenWidth!
        )
        self.thumbNail.image = thumbNail == nil ? NO_IMG?.resize(size: thumbSize) : thumbNail?.resize(size: thumbSize)
    }
}

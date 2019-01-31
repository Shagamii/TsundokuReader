//
//  DetailViewController.swift
//  TsundokuReader
//
//  Created by Ryuichi Sakagami on 2019/01/31.
//  Copyright © 2019 Ryuichi Sakagami. All rights reserved.
//

import UIKit
import RealmSwift

let NOT_FOUND_TITLE = "タイトルを取得できませんでした。"

class DetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var link: UITextView!
    @IBOutlet weak var memo: UITextView!
    var info: Tsundoku!
    var updateItem: ((Tsundoku) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = info.title ?? NOT_FOUND_TITLE
        detailTitle.text = info.title ?? NOT_FOUND_TITLE
        link.text = info.url
        memo.text = info.memo
        let screenWidth = UIScreen.main.bounds.width
        let thumbSize = CGSize(
            width: screenWidth,
            height: screenWidth
        )
        thumbNail.image = info.thumbNail == nil ? NO_IMG?.resize(size: thumbSize) : info.thumbNail?.resize(size: thumbSize)
    }
    

    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */

    @IBAction func handleTapUpdateButton(_ sender: UIButton) {
        self.updateItem(createTsundoku(
            id: info.id,
            title: info.title,
            createdAt: info.createdAt,
            url: info.url,
            imgUrl: info.imgUrl,
            memo: memo.text,
            thumbNail: info.thumbNail
        ))
    }
    
}

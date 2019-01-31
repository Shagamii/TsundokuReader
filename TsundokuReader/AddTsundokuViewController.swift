//
//  AddTsundokuViewController.swift
//  TsundokuReader
//
//  Created by Ryuichi Sakagami on 2019/01/31.
//  Copyright © 2019 Ryuichi Sakagami. All rights reserved.
//

import UIKit
import OpenGraph

func generate(length: Int) -> String {
    let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var randomString: String = ""
    
    for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(base.count))
        randomString += "\(base[base.index(base.startIndex, offsetBy: randomValue)])"
    }
    return randomString
}

class AddTsundokuViewController: UIViewController {
    
    @IBOutlet weak var url: UITextField!
    @IBOutlet weak var memo: UITextView!
    var addItem: ((Tsundoku) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleClickSaveButton(_ sender: UIButton) {
        if url.text!.count > 0 {
            DispatchQueue.main.async {
                self.addItem(createTsundoku(
                    id: generate(length: 10),
                    title: nil,
                    createdAt: Date(),
                    url: self.url.text!,
                    imgUrl: nil,
                    memo: self.memo.text,
                    thumbNail: nil
                ))
                self.url.text = "https://"
                self.memo.text = ""
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

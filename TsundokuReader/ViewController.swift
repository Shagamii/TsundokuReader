//
//  ViewController.swift
//  TsundokuReader
//
//  Created by Ryuichi Sakagami on 2019/01/30.
//  Copyright © 2019 Ryuichi Sakagami. All rights reserved.
//

import UIKit
import OpenGraph
import RealmSwift

class Tsundoku: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String?
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var url: String = ""
    @objc dynamic var imgUrl: String?
    @objc dynamic var memo: String?
    var thumbNail: UIImage?
}

func createTsundoku (
    id: String,
    title: String?,
    createdAt: Date,
    url: String,
    imgUrl: String?,
    memo: String?,
    thumbNail: UIImage?
    ) -> Tsundoku {
    let t = Tsundoku()
    t.id = id
    t.title = title
    t.createdAt = createdAt
    t.url = url
    t.imgUrl = imgUrl
    t.memo = memo
    t.thumbNail = thumbNail
    return t
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationButton: UIButton!
    var formatter = Formatter()
    var items: [Tsundoku] = []
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "積ん読リーダー"
        navigationItem.rightBarButtonItem = editButtonItem
        self.loadData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: "CardTableViewCell")
        navigationButton.backgroundColor = UIColor.white
        navigationButton.layer.cornerRadius = 25
        navigationButton.layer.shadowOffset = CGSize(
            width: 0.3,
            height: 0.3
        )
        navigationButton.layer.shadowOpacity = 0.7
        navigationButton.layer.shadowRadius = 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedRow = tableView.indexPathForSelectedRow  {
            if segue.identifier == "CardToDetail" {
                let controller = segue.destination as! DetailViewController
                controller.info = items[selectedRow.row]
                controller.updateItem = updateItem
            }
            else {
                let controller = segue.destination as! AddTsundokuViewController
                controller.addItem = self.addItem
            }
        }
        else {
            let controller = segue.destination as! AddTsundokuViewController
            controller.addItem = self.addItem
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "CardToDetail", sender: self.tableView)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing //editingはBool型でeditButtonに依存する変数
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .none)
        DispatchQueue.main.async {
            let realm = try! Realm()
            try! realm.write() {
                realm.deleteAll()
            }
            self.items.forEach { item in
                print(item)
                try! realm.write() {
                    realm.add(item)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            let deleteItem = self.items[indexPath.row]
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            DispatchQueue.main.async {
                let realm = try! Realm()
                Array(realm.objects(Tsundoku.self)).forEach { item in
                    if item.id == deleteItem.id {
                        try! realm.write() {
                            realm.delete(item)
                        }
                    }
                }
            }
        }
        deleteButton.backgroundColor = UIColor.red
        
        return [deleteButton]
    }
    
    func updateItem(tsundoku: Tsundoku) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            Array(realm.objects(Tsundoku.self)).forEach { item in
                if item.id == tsundoku.id {
                    try! realm.write() {
                        item.memo = tsundoku.memo
                    }
                }
            }
            let newItems = self.items.map { $0.id == tsundoku.id ? tsundoku : $0 }
            self.items = newItems
            self.tableView.reloadData()
        }
    }
    
    func addItem(tsundoku: Tsundoku) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            try! realm.write() {
                realm.add(tsundoku)
            }
            self.fetchData(fetchItems: [tsundoku])
        }
    }
    
    func fetchData(fetchItems: [Tsundoku]) {
        fetchItems.forEach { item in
            let tenDaysAgo = Date(timeIntervalSinceNow:-60*60*24*10)
            if item.imgUrl != nil && tenDaysAgo < item.createdAt {
                self.items.append(item)
            }
            
            if let itemUrl = URL(string: item.url) {
                OpenGraph.fetch(url: itemUrl) { og, error in
                    let title = og?[.title]
                    let imgUrl = og?[.image]
                    if let imgUrl = imgUrl, let url = URL(string: imgUrl) {
                        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                            let img = UIImage(data: data!)
                            if let img = img {
                                DispatchQueue.main.async {
                                    self.items.append(createTsundoku(
                                        id: item.id,
                                        title: title,
                                        createdAt: item.createdAt,
                                        url: item.url,
                                        imgUrl: imgUrl,
                                        memo: item.memo,
                                        thumbNail: img
                                    ))
                                    self.tableView.reloadData()
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.items.append(createTsundoku(
                                        id: item.id,
                                        title: title,
                                        createdAt: item.createdAt,
                                        url: item.url,
                                        imgUrl: imgUrl,
                                        memo: item.memo,
                                        thumbNail: nil
                                    ))
                                    self.tableView.reloadData()
                                }
                            }
                        }).resume()
                    }
                    else {
                        DispatchQueue.main.async {
                            self.items.append(createTsundoku(
                                id: item.id,
                                title: title,
                                createdAt: item.createdAt,
                                url: item.url,
                                imgUrl: imgUrl,
                                memo: item.memo,
                                thumbNail: nil
                            ))
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func loadData() {
        let realm = try! Realm()
        let loadData = Array(realm.objects(Tsundoku.self))
        self.fetchData(fetchItems: loadData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell") as! CardTableViewCell
        let item = items[indexPath.row]
        cell.layer.masksToBounds = false
        cell.layer.zPosition = 1
        cell.setProps(props: item)
        return cell
    }
}


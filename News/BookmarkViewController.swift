//
//  BookmarkViewController.swift
//  News
//
//  Created by Souvik Das on 30/12/20.
//

import UIKit
import RealmSwift

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table : UITableView!
    
    private var data = [BookmarkItem]()
    private let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = realm.objects(BookmarkItem.self).map({$0})
//        data.sort {($0.id > $1.id)}
        data.reverse()
        table.delegate = self
        table.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //FUNCTION USED TO SET TABLE DATA
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath)
        let i = data[indexPath.row].title
        let d = data[indexPath.row].desc
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = i
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = d
        
        return cell
    }
    
    //FUNCTION USED TO SHOW A SPECIFIC ROW DATA
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = data[indexPath.row]
        guard let vc = storyboard?.instantiateViewController(identifier: "viewer") as? ViewerViewController else {
            return
        }
        vc.myURL = item.url
        vc.navigationItem.largeTitleDisplayMode = .never
//        present(vc, animated: true, completion: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let item = data[indexPath.row]
            realm.beginWrite()
            realm.delete(item)
            try! realm.commitWrite()
            self.refresh()
        }
    }
    func refresh(){
        data = realm.objects(BookmarkItem.self).map({$0})
        data.reverse()
        table.reloadData()
    }


}

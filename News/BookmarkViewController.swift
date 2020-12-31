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
    @IBOutlet var elf: UIButton!
    
    private var data = [BookmarkItem]()
    private let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = realm.objects(BookmarkItem.self).map({$0})
        data.reverse()
        if data.isEmpty{
            table.isHidden = true
            showLabel(controller: self, message: "Swipe on news to bookmark them!")
        }
        else{
            table.isHidden = false
            table.delegate = self
            table.dataSource = self
        }
    }
    func showLabel(controller: UIViewController, message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        controller.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func didTapElf(){
        updateElf()
    }
    @IBAction func didTapDeleteAll(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        refresh()
    }
    func updateElf(){
        UIView.animate(withDuration: 2.0) { () -> Void in
            self.elf.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
            self.elf.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
        }, completion: nil)
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
        cell.detailTextLabel?.textColor = .darkGray
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            let item = self.data[indexPath.row]
            self.realm.beginWrite()
            self.realm.delete(item)
            try! self.realm.commitWrite()
            self.refresh()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            let item = self.data[indexPath.row]
            self.realm.beginWrite()
            self.realm.delete(item)
            try! self.realm.commitWrite()
            self.refresh()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    func refresh(){
        data = realm.objects(BookmarkItem.self).map({$0})
        data.reverse()
        table.reloadData()
    }
    


}

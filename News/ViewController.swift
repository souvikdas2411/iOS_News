//
//  ViewController.swift
//  News
//
//  Created by Souvik Das on 28/12/20.
//

import UIKit
import SwiftyJSON
import SDWebImage
import JGProgressHUD


struct dataType: Identifiable{
    var id: String
    var title: String
    var desc: String
    var url: String
    var image: String
}
var datas = [dataType]()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getData(source: "https://newsapi.org/v2/top-headlines?country=in&apiKey=a086df1105b44d51bc72a98d7ca0bf19")
//        tableView.isHidden = true
//        hud.show(in: self.view)
//        hud.textLabel.text = "HackerNews Loading"
//        getHack()
    }
    
    @IBAction func didTapApple(){
//                tableView.isHidden = true
        datas.removeAll()
        tableView.reloadData()
        getData(source: "https://newsapi.org/v2/everything?q=apple&from=2020-12-26&to=2020-12-26&sortBy=popularity&apiKey=a086df1105b44d51bc72a98d7ca0bf19")
    }
    @IBAction func didTapBusiness(){
//                tableView.isHidden = true
        datas.removeAll()
        tableView.reloadData()
        getData(source: "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=a086df1105b44d51bc72a98d7ca0bf19")
    }
    @IBAction func didTapHack(){
        
//        tableView.isHidden = true
//        hud.show(in: self.view)
//        hud.textLabel.text = "HackerNews Loading"
        datas.removeAll()
        tableView.reloadData()
        getHack()
    }
    @IBAction func didTapIndia(){
//                tableView.isHidden = true
        datas.removeAll()
        tableView.reloadData()
        getData(source: "https://newsapi.org/v2/top-headlines?country=in&apiKey=a086df1105b44d51bc72a98d7ca0bf19")
    }
    func getData(source: String){
        let url = URL(string: source)!
        let session = URLSession(configuration: .default)
        session.dataTask(with: url){ (data, _, error) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            let json = try! JSON(data: data!)
            // refer to news api doc for details of the code below
            for i in json["articles"]{
                
                let title = i.1["title"].stringValue
                let descriiption = i.1["description"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let publishedAt = i.1["publishedAt"].stringValue
                
                DispatchQueue.main.async {
                    datas.append(dataType(id: publishedAt, title: title, desc: descriiption, url: url, image: image))
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
//                    self.tableView.isHidden = false
                }
            }
            
        }.resume()
    }
    func getHack(){
        let source = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
        let url = URL(string: source)!
        let session = URLSession(configuration: .default)
        session.dataTask(with: url){ (data, _, error) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            let json = try! JSON(data: data!)
            for i in json[]{
                let temp = i.1[]
                let hackSource = "https://hacker-news.firebaseio.com/v0/item/\(temp).json?print=pretty"
                let hackUrl = URL(string: hackSource)!
                let hackSession = URLSession(configuration: .default)
                hackSession.dataTask(with: hackUrl) {(hackData,_,hackError) in
                    if hackError != nil{
                        print(hackError?.localizedDescription)
                        return
                    }
                    let hackJson = try! JSON(data: hackData!)
                    let title = hackJson["title"].stringValue
                    let descriiption = hackJson["by"].stringValue
                    let url = hackJson["url"].stringValue
                    let hackId = hackJson["time"].stringValue
                    DispatchQueue.main.async {
                        datas.append(dataType(id: hackId, title: title, desc: descriiption, url: url, image: ""))
                        //self.tableView.isUserInteractionEnabled = true
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                    }
                    
                }.resume()
            }
            
        
            
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = datas[indexPath.row].title
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = datas[indexPath.row].desc
        //        let url = URL(string: datas[indexPath.row].image)
        //        cell.imageView.image = SDWebImageDownloader.downloadImage(with: url, completed: nil)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("tapped")
        
        let item = datas[indexPath.row].url
        guard let vc = storyboard?.instantiateViewController(identifier: "viewer") as? ViewerViewController else {
            return
        }
        vc.myURL = item
        vc.navigationItem.largeTitleDisplayMode = .never
//        present(vc, animated: true, completion: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
}


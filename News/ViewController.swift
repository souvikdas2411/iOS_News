//
//  ViewController.swift
//  News
//
//  Created by Souvik Das on 28/12/20.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Network
import RealmSwift

struct dataType: Identifiable{
    var id: String
    var title: String
    var desc: String
    var url: String
    var image: String
}
class BookmarkItem: Object{
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var image: String = ""
}
//prevIndex not in use
var prevIndex = IndexPath()
var datas = [dataType]()
var results = [dataType]()
var sel = [Cell]()
var defURL = ""
var scrollDatas = ["Headlines Google","Headlines India","Headlines US","India Business Headlines","Hacker News Best","Hacker News New","Hacker News Top","Hacker News Show","Hacker News Jobs","Tech Scrape"]
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var bookmarks = [BookmarkItem]()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var timeLabel: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var corona: UIButton!
    
    private var hasFetched = false
    var refreshControl = UIRefreshControl()
    
    private let realm = try! Realm()
    
    let monitor = NWPathMonitor()
    
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.title = "Headlines Google"
        defURL = "https://newsapi.org/v2/top-headlines?sources=google-news-in&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
        getData(source: defURL)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        searchBar.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        //collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        ///DARK MODE PROGRAMATICALLY
//        self.overrideUserInterfaceStyle = .dark
        
        dateFormatter.dateStyle = .full
        Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(self.updateClock), userInfo: nil, repeats: true)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                //self.refresh(self)
                self.showToast(controller: self, message: "Connection restored!", seconds: 1)
            } else {
                self.showToast(controller: self, message: "No internet connection!", seconds: 3)
            }
        }
        
        monitor.start(queue: DispatchQueue.main)
        
    }
    @objc func refresh(_ sender: AnyObject) {
        datas.removeAll()
        tableView.reloadData()
        if defURL == "https://hacker-news.firebaseio.com/v0/beststories.json?print=pretty"{
            getHack(source: defURL)
        }
        else {
            getData(source: defURL)
        }
        
    }
    
    @objc func updateClock(){
        timeLabel.title = dateFormatter.string(from: Date())
        
    }
    
    @IBAction func didTapCorona(){
        UIView.animate(withDuration: 2.0) { () -> Void in
            self.corona.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
            self.corona.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
        }, completion: nil)
        getCorona()
    }
    @IBAction func didTapBookmark(){
        guard let vc = storyboard?.instantiateViewController(identifier: "bookmark") as? BookmarkViewController else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    func getData(source: String){
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        let url = URL(string: source)!
        let session = URLSession(configuration: .default)
        session.dataTask(with: url){ (data, _, error) in
            if error != nil{
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
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
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.refreshControl.endRefreshing()
                }
            }
            
            
        }.resume()
    }
    func getHack(source: String){
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        let url = URL(string: source)!
        let session = URLSession(configuration: .default)
        session.dataTask(with: url){ (data, _, error) in
            if error != nil{
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
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
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        print(hackError?.localizedDescription)
                        return
                    }
                    let hackJson = try! JSON(data: hackData!)
                    let title = hackJson["title"].stringValue
                    //description changed from by to url
                    let descriiption = hackJson["url"].stringValue
                    let url = hackJson["url"].stringValue
                    let hackId = hackJson["time"].stringValue
                    DispatchQueue.main.async {
                        datas.append(dataType(id: hackId, title: title, desc: descriiption, url: url, image: ""))
                        //self.tableView.isUserInteractionEnabled = true
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    
                }.resume()
            }
            
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasFetched{
            return results.count
        }
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if hasFetched{
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.text = results[indexPath.row].title
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.textColor = .darkGray
            cell.detailTextLabel?.text = results[indexPath.row].desc
            return cell
        }
        let url = URL(string: datas[indexPath.row].image)
//        cell.imageView?.sd_setImage(with: url, completed: nil)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = datas[indexPath.row].title
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.textColor = .darkGray
        cell.detailTextLabel?.text = datas[indexPath.row].desc
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if hasFetched{
            let item = results[indexPath.row].url
            if item == ""{
                return
            }
            guard let vc = storyboard?.instantiateViewController(identifier: "viewer") as? ViewerViewController else {
                return
            }
            vc.myURL = item
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let item = datas[indexPath.row].url
            if item == ""{
                brokenLink(controller: self, message: "Oops!Something went wrong.", seconds: 1)
                return
            }
            guard let vc = storyboard?.instantiateViewController(identifier: "viewer") as? ViewerViewController else {
                return
            }
            vc.myURL = item
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
            if !self.hasFetched{
                self.bookmarks.removeAll()
                self.bookmarks = self.realm.objects(BookmarkItem.self).map({$0})
                let item = datas[indexPath.row]
                let temp: BookmarkItem = {
                    let temp1 = BookmarkItem()
                    temp1.id = item.id
                    temp1.desc = item.desc
                    temp1.image = item.image
                    temp1.url = item.url
                    temp1.title = item.title
                    return temp1
                }()
                let count = self.bookmarks.count
                for i in 0..<count{
                    if self.bookmarks[i].url == temp.url && self.bookmarks[i].id == temp.id{
                        self.showToast(controller: self, message: "Bookmark exists!", seconds: 1)
                        completionHandler(true)
                        return
                    }
                }
                self.realm.beginWrite()
                self.realm.add(temp)
                try! self.realm.commitWrite()
                
                self.showToast(controller: self, message: "Bookmarked!", seconds: 1)
                completionHandler(true)
            }
            else{
                self.hasFetched = false
                self.bookmarks.removeAll()
                self.bookmarks = self.realm.objects(BookmarkItem.self).map({$0})
                let item = results[indexPath.row]
                let temp: BookmarkItem = {
                    let temp1 = BookmarkItem()
                    temp1.id = item.id
                    temp1.desc = item.desc
                    temp1.image = item.image
                    temp1.url = item.url
                    temp1.title = item.title
                    return temp1
                }()
                let count = self.bookmarks.count
                for i in 0..<count{
                    if self.bookmarks[i].url == temp.url && self.bookmarks[i].id == temp.id{
                        self.showToast(controller: self, message: "Bookmark exists!", seconds: 1)
                        completionHandler(true)
                        return
                    }
                }
                self.realm.beginWrite()
                self.realm.add(temp)
                try! self.realm.commitWrite()
                
                self.showToast(controller: self, message: "Bookmarked!", seconds: 1)
                completionHandler(true)
            }
            
        }
        deleteAction.image = UIImage(systemName: "bookmark")
        deleteAction.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
            if !self.hasFetched{
                self.bookmarks.removeAll()
                self.bookmarks = self.realm.objects(BookmarkItem.self).map({$0})
                let item = datas[indexPath.row]
                let temp: BookmarkItem = {
                    let temp1 = BookmarkItem()
                    temp1.id = item.id
                    temp1.desc = item.desc
                    temp1.image = item.image
                    temp1.url = item.url
                    temp1.title = item.title
                    return temp1
                }()
                let count = self.bookmarks.count
                for i in 0..<count{
                    if self.bookmarks[i].url == temp.url && self.bookmarks[i].id == temp.id{
                        self.showToast(controller: self, message: "Bookmark exists!", seconds: 1)
                        completionHandler(true)
                        return
                    }
                }
                self.realm.beginWrite()
                self.realm.add(temp)
                try! self.realm.commitWrite()
                
                self.showToast(controller: self, message: "Bookmarked!", seconds: 1)
                completionHandler(true)
            }
            else{
                self.hasFetched = false
                self.bookmarks.removeAll()
                self.bookmarks = self.realm.objects(BookmarkItem.self).map({$0})
                let item = results[indexPath.row]
                let temp: BookmarkItem = {
                    let temp1 = BookmarkItem()
                    temp1.id = item.id
                    temp1.desc = item.desc
                    temp1.image = item.image
                    temp1.url = item.url
                    temp1.title = item.title
                    return temp1
                }()
                let count = self.bookmarks.count
                for i in 0..<count{
                    if self.bookmarks[i].url == temp.url && self.bookmarks[i].id == temp.id{
                        self.showToast(controller: self, message: "Bookmark exists!", seconds: 1)
                        completionHandler(true)
                        return
                    }
                }
                self.realm.beginWrite()
                self.realm.add(temp)
                try! self.realm.commitWrite()
                
                self.showToast(controller: self, message: "Bookmarked!", seconds: 1)
                completionHandler(true)
            }
            
        }
        deleteAction.image = UIImage(systemName: "bookmark")
        deleteAction.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
            
    }
    // Create a standard header that includes the returned text.
//    func tableView(_ tableView: UITableView, titleForHeaderInSection
//                                section: Int) -> String? {
//       return "Header \(section)"
//    }

    // Create a standard footer that includes the returned text.
//    func tableView(_ tableView: UITableView, titleForFooterInSection
//                                section: Int) -> String? {
//       return "Footer \(section)"
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scrollDatas.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellC", for: indexPath) as! Cell
        cell.layer.cornerRadius = 18.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.systemBlue.cgColor
        cell.textLabel.text = scrollDatas[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell

        //Hardcoded this part. Need an alternative
        if cell.textLabel.text == "Headlines Google"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "Headlines Google"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://newsapi.org/v2/top-headlines?sources=google-news-in&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
            self.getData(source: defURL)
        }
        if cell.textLabel.text == "Headlines India"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "Headlines India"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://newsapi.org/v2/top-headlines?country=in&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
            self.getData(source: defURL)
        }
        if cell.textLabel.text == "Headlines US"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "Headlines US"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://newsapi.org/v2/top-headlines?country=us&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
            self.getData(source: defURL)
        }
        if cell.textLabel.text == "India Business Headlines"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "India Business Headlines"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://newsapi.org/v2/top-headlines?country=in&category=business&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
            self.getData(source: defURL)
        }
        if cell.textLabel.text == "Hacker News Best"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "HackerNews Best"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://hacker-news.firebaseio.com/v0/beststories.json?print=pretty"
            self.getHack(source: defURL)
        }
        if cell.textLabel.text == "Hacker News Top"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "HackerNews Top"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
            self.getHack(source: defURL)
        }
        if cell.textLabel.text == "Hacker News New"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "HackerNews New"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty"
            self.getHack(source: defURL)
        }
        if cell.textLabel.text == "Hacker News Show"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "HackerNews Show"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://hacker-news.firebaseio.com/v0/showstories.json?print=pretty"
            self.getHack(source: defURL)
        }
        if cell.textLabel.text == "Hacker News Jobs"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "HackerNews Jobs"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://hacker-news.firebaseio.com/v0/jobstories.json?print=pretty"
            self.getHack(source: defURL)
        }
        if cell.textLabel.text == "Tech Scrape"{
            hasFetched = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.title = "Tech Scrape"
            datas.removeAll()
            self.tableView.reloadData()
            defURL = "https://newsapi.org/v2/everything?domains=thenextweb.com,wired.com,tech2.com&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
            self.getData(source: defURL)
        }
//        if cell.textLabel.text == "Covid Scrape"{
//            self.title = "Covid Scrape"
//            datas.removeAll()
//            self.tableView.reloadData()
//            defURL = "https://newsapi.org/v2/everything?q=corona&sortBy=popularity&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
//            self.getData(source: defURL)
//        }
    
    }
}


//MARK:- Search bar delegate
extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            hasFetched = false
            tableView.reloadData()
            return
        }
        
        
        searchBar.resignFirstResponder()
        results.removeAll()
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        for i in datas{
            if i.title.lowercased().contains(query.lowercased()) || i.desc.lowercased().contains(query.lowercased()){
                results.append(dataType(id: i.id, title: i.title, desc: i.desc, url: i.url, image: i.image))
                hasFetched = true
                tableView.reloadData()
            }
        }
        if results.isEmpty {
            searchBar.text = ""
            showToast(controller: self, message: "Oops! No results found.", seconds: 1.0)
        }
    }
    
    func showToast(controller: UIViewController, message: String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        controller.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    func showCorona(controller: UIViewController, message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        controller.present(alert, animated: true, completion: nil)
        
    }
    func getCorona(){
        let headers = [
            "x-rapidapi-key": "cb3b31426dmsh9e8f5509ac874dep19234cjsn368eafc7208f",
            "x-rapidapi-host": "covid-19-data.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://covid-19-data.p.rapidapi.com/totals")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let json = try! JSON(data: data!)
                for i in json[]{
                    DispatchQueue.main.async {
                        self.showCorona(controller: self, message: "COVID-19 Confirmed- \(i.1["confirmed"])/ Deaths- \(i.1["deaths"])/ Recovered- \(i.1["recovered"])")
                    }
                }
                
            }
        })
        
        dataTask.resume()
    }
    //    func presentActionSheet() {
    //        let actionSheet = UIAlertController(title: NSLocalizedString("Sources", comment: "") ,
    //                                            message: NSLocalizedString("Select source below", comment: ""),
    //                                            preferredStyle: .actionSheet)
    //        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
    //                                            style: .cancel,
    //                                            handler: nil))
    //        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Headlines India", comment: ""),
    //                                            style: .default,
    //                                            handler: { [weak self] _ in
    //
    //                                                self?.title = "India News"
    //                                                datas.removeAll()
    //                                                self?.tableView.reloadData()
    //                                                defURL = "https://newsapi.org/v2/top-headlines?country=in&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
    //                                                self?.getData(source: defURL)
    //
    //                                            }))
    //        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Headlines US", comment: ""),
    //                                            style: .default,
    //                                            handler: { [weak self] _ in
    //
    //                                                self?.title = "US News"
    //                                                datas.removeAll()
    //                                                self?.tableView.reloadData()
    //                                                defURL = "https://newsapi.org/v2/top-headlines?country=us&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
    //                                                self?.getData(source: defURL)
    //
    //                                            }))
    //        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("India Business Headlines", comment: ""),
    //                                            style: .default,
    //                                            handler: { [weak self] _ in
    //
    //                                                self?.title = "Business News"
    //                                                datas.removeAll()
    //                                                self?.tableView.reloadData()
    //                                                defURL = "https://newsapi.org/v2/top-headlines?country=in&category=business&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
    //                                                self?.getData(source: defURL)
    //
    //                                            }))
    //        //Some NSURLProblem
    ////        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Headlines BBC", comment: ""),
    ////                                            style: .default,
    ////                                            handler: { [weak self] _ in
    ////
    ////                                                self?.title = "Business News"
    ////                                                datas.removeAll()
    ////                                                self?.tableView.reloadData()
    ////                                                defURL = "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
    ////                                                self?.getData(source: defURL)
    ////
    ////                                            }))
    //        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Hacker News", comment: ""),
    //                                            style: .default,
    //                                            handler: { [weak self] _ in
    //
    //                                                self?.title = "Hacker News"
    //                                                datas.removeAll()
    //                                                self?.tableView.reloadData()
    //                                                defURL = "https://hacker-news.firebaseio.com/v0/beststories.json?print=pretty"
    //                                                self?.getHack(source: defURL)
    //
    //                                            }))
    //        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Tech scrape", comment: ""),
    //                                            style: .default,
    //                                            handler: { [weak self] _ in
    //
    //                                                self?.title = "Tech News"
    //                                                datas.removeAll()
    //                                                self?.tableView.reloadData()
    //                                                defURL = "https://newsapi.org/v2/everything?domains=thenextweb.com&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
    //                                                self?.getData(source: defURL)
    //
    //
    //                                            }))
    ////        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Startup scrape", comment: ""),
    ////                                            style: .default,
    ////                                            handler: { [weak self] _ in
    ////
    ////                                                self?.title = "Apple News"
    ////                                                datas.removeAll()
    ////                                                self?.tableView.reloadData()
    ////                                                defURL = "https://newsapi.org/v2/everything?q=startup&from=2020-12-28&to=2020-12-28&sortBy=popularity&apiKey=a086df1105b44d51bc72a98d7ca0bf19"
    ////                                                self?.getData(source: defURL)
    ////
    ////
    ////                                            }))
    //
    //        //iPad Alert Controller
    //        actionSheet.popoverPresentationController?.barButtonItem = self.timeLabel
    //
    //        present(actionSheet, animated: true)
    //    }
    func brokenLink(controller: UIViewController, message: String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        controller.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds){
            alert.dismiss(animated: true, completion: nil)
        }
    }
}



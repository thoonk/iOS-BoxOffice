//
//  TableViewController.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import UIKit

import UIKit

class TableViewController: UIViewController, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier: String = "tableCell"
    var movies: [Movie] = []
    
    @IBAction func touchUpSettingButton(_ sender: UIBarButtonItem){
        selectOrder(controller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "예매율"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidRecieveMoviesNotification, object: nil)
    }
    
    @objc func didReceiveMoviesNotification(_ noti: Notification){
        guard let movies: [Movie] = noti.userInfo?["movies"] as? [Movie] else {return}
        
        self.movies = movies
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestMovies(orderType: 0)
    }
    
    //REMARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MovieTableViewCell
        
        let movie: Movie = self.movies[indexPath.row]
        
        cell.thumbImageView?.image = nil
        cell.titleLabel?.text = movie.title
        cell.detailLabel?.text = movie.tableSecond
        cell.dateLabel?.text = "개봉일: \(movie.date)"
        
        DispatchQueue.global(qos: .background).async {

            guard let imageURL: URL = URL(string: movie.thumb) else {
                print("url error")
                return
                
            }
            // ATS로 인하여 http인 경우 Info.plist에서 ATS비활성화해야 함
            guard let imageData: Data = try? Data(contentsOf: imageURL) else {
                print("data error")
                return
                
            }
            
            DispatchQueue.main.async {
                if let index: IndexPath = tableView.indexPath(for: cell){
                    if index.row == indexPath.row{
                        cell.thumbImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        }
        return cell
    }

}



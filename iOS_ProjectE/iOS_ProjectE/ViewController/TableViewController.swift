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
    var movies: [Movies] = []
    
    @IBAction func touchUpSettingButton(_ sender: UIBarButtonItem){
        selectOrder(controller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "예매율"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidRecieveMoviesNotification, object: nil)
    }
    
    @objc func didReceiveMoviesNotification(_ noti: Notification){
        guard let movies: [Movies] = noti.userInfo?["movies"] as? [Movies] else {return}
        
        self.movies = movies
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestMovies(orderType: 0)
    }
    
    // MARK: - setGrandImageView
    func setGradeImageView(_ imageView: UIImageView, grade: Int) {
        if grade == 0 {
            imageView.image = UIImage(named: "ic_allages")
        } else if grade == 12 {
            imageView.image = UIImage(named: "ic_12")
        } else if grade == 15 {
            imageView.image = UIImage(named: "ic_15")
        } else {
            imageView.image = UIImage(named: "ic_19")
        }
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MovieTableViewCell
        
        let movies: Movies = self.movies[indexPath.row]
        
        cell.thumbImageView?.image = nil
        cell.titleLabel?.text = movies.title
        cell.detailLabel?.text = movies.tableSecond
        cell.dateLabel?.text = "개봉일: \(movies.date)"
        setGradeImageView(cell.gradeImageView, grade: movies.grade)
        
        DispatchQueue.global(qos: .background).async {

            guard let imageURL: URL = URL(string: movies.thumb) else {
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailFromTable" {
            guard let detailVC: DetailViewController = segue.destination as? DetailViewController else {
                return
            }
            
            guard let moviesData = sender as? Movies else {
                return
            }
            
            detailVC.moviesData = moviesData
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}



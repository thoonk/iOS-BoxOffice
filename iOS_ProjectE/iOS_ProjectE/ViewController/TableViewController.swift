//
//  TableViewController.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import UIKit

import UIKit

class TableViewController: MovieViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView! {
        didSet{
            indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: false)
        }
    }
    
    let cellIdentifier: String = "tableCell"
    let segueIdentifier: String = "toDetailFromTable"
    
    var refresher = UIRefreshControl()
    var movies: [Movies?] = []
    
    @IBAction func touchUpSettingButton(_ sender: UIBarButtonItem){
        setOrderType()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refresher)
        registerOrderTypeNotification()
        requestMovies()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavigationTitle()
    }
    
    override func didReceiveNotification(_ notification: Notification) {
        super.didReceiveNotification(notification)
        changeNavigationTitle()
        requestMovies()
    }
    
    @objc private func refresh() {
        requestMovies()
    }
    
    // 네비게이션 타이틀 변경
    private func changeNavigationTitle() {
        switch Request.orderType {
        case .reservationRate:
            navigationItem.title = "예매율"
        case .curation:
            navigationItem.title = "큐레이션"
        case .date:
            navigationItem.title = "개봉일"
        }
    }
    
    // 영화 목록 요청
    private func requestMovies(){
        if !refresher.isRefreshing {
            indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: true)
        }
        request.requestMovies(Request.orderType) { [weak self ] (isSuccess, data, error) in
            guard let self = self else { return }
            if let error = error {
                self.errorHandler(error) {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
                    self.tableView.isHidden = true
                }
            }
            if isSuccess {
                guard let movieList = data as? [Movies] else {
                    return
                }
                
                self.movies = movieList
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.errorHandler() {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
                    self.tableView.isHidden = true
                }
            }
        }
        indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: false)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MovieTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieTableViewCell, let movies: Movies = self.movies[indexPath.row] else{
            return UITableViewCell()
        }
            
        cell.mappingData(movies)
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
        if segue.identifier == segueIdentifier {
            
            guard let cell: UITableViewCell = sender as? UITableViewCell else{ return}
            guard let index: IndexPath = self.tableView.indexPath(for: cell) else {return}
            
            guard let detailVC: DetailViewController = segue.destination as? DetailViewController else {
                print("no movie in tableview")
                return
            }
            
            detailVC.movies = movies[index.row]
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}



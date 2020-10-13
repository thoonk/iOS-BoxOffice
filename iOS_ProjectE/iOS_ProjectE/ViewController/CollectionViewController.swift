//
//  CollectionViewController.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import UIKit

class CollectionViewController: MovieViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView! {
        didSet{
            indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: false)
        }
    }

    
    let cellIdentifier: String = "collectionCell"
    let segueIdentifier: String = "toDetailFromCollection"

    var refresher = UIRefreshControl()
    var movies: [Movies?] = []
    
    @IBAction func touchUpSettingButton(_ sender: UIBarButtonItem){
        setOrderType()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // flowLayout 설정
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        let halfWidth: CGFloat = UIScreen.main.bounds.width / 2.0
        flowLayout.itemSize = CGSize(width: halfWidth - 30 , height: halfWidth + 70)
        self.collectionView.collectionViewLayout = flowLayout
        
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refresher)
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
                    self.collectionView.isHidden = true
                }
            }
            if isSuccess {
                guard let movieList = data as? [Movies] else {
                    return
                }
                
                self.movies = movieList
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                self.errorHandler() {
                    self.indicatorViewAnimating(self.activityIndicatorView, refresher: self.refresher, isStart: false)
                    self.collectionView.isHidden = true
                }
            }
        }
        indicatorViewAnimating(activityIndicatorView, refresher: refresher, isStart: false)
    }

            
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: MovieCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? MovieCollectionViewCell, let movies: Movies = self.movies[indexPath.item] else {return UICollectionViewCell()}
                
        cell.mappingData(movies)
        setGradeImageView(cell.gradeImageView, grade: movies.grade)
        
        DispatchQueue.global(qos: .background).async {
        
            guard let imageURL: URL = URL(string: movies.thumb) else{
                print("url error")
                return
            }
            
            guard let imageData: Data = try? Data(contentsOf: imageURL) else {
                print("data error")
                return
            }
            
            DispatchQueue.main.async {
                if let index: IndexPath = collectionView.indexPath(for: cell){
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
            
            guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else{ return}
            guard let index: IndexPath = self.collectionView.indexPath(for: cell) else {return}
            
            guard let detailVC: DetailViewController = segue.destination as? DetailViewController else {
                print("no movie in tableview")
                return
            }
            
            detailVC.movies = movies[index.row]
        }
        //         // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

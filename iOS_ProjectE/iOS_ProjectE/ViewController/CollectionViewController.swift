//
//  CollectionViewController.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellIdentifier: String = "collectionCell"
    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //flowLayout.sectionInset = UIEdgeInsets.zero
        //flowLayout.minimumInteritemSpacing = 10
        //flowLayout.minimumLineSpacing = 10
        
        let halfWidth: CGFloat = UIScreen.main.bounds.width / 2.0
        
        flowLayout.estimatedItemSize = CGSize(width: halfWidth - 37 , height: halfWidth + 33)
        
        self.collectionView.collectionViewLayout = flowLayout
        
        self.navigationItem.title = "예매율"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidRecieveMoviesNotification, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestMovies(orderType: 0)
    }
    
    @objc func didReceiveMoviesNotification(_ noti: Notification){
        guard let movies: [Movie] = noti.userInfo?["movies"] as? [Movie] else {return}
        
        self.movies = movies
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    //REMARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: MovieCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? MovieCollectionViewCell else {return UICollectionViewCell()}
        
        let movie: Movie = self.movies[indexPath.item]
        
        cell.thumbImageView?.image = nil
        cell.titleLabel?.text = movie.title
        cell.detailLabel?.text = movie.collectionSecond
        cell.dateLabel?.text = movie.date
        
        DispatchQueue.global(qos: .background).async {
            
            guard let imageURL: URL = URL(string: movie.thumb) else{
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

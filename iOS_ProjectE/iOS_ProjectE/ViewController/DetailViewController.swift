//
//  DetailViewController.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/02.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movie: Movie?
    var movies: Movies?
    
    struct TableViewSection{
        static let info = 0
        static let synopsis = 1
        static let directorActor = 2
        static let comment = 3
    }
    struct CellIdentifier{
        static let infoCell = "infoCell"
        static let synopsisCell = "synopsisCell"
        static let directorActorCell = "directorActorCell"
        static let commentCell = "commentCell"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let movies = movies else{
            return
        }
        requestMovieDetail(movies.id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMovieNotification(_:)), name: DidRecieveMovieNotification, object: nil)
    }
    
    @objc func didReceiveMovieNotification(_ noti: Notification){
        guard let movie: Movie = noti.userInfo?["movie"] as? Movie else {
            print("noti error")
            return}
        
        self.movie = movie
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movie = movie else{
            return UITableViewCell()
        }
        switch indexPath.section{
        case TableViewSection.info:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.infoCell, for: indexPath) as? InfoTableViewCell else {
                return UITableViewCell()
                
            }
            cell.titleLabel.text = movie.title
            cell.dateLabel.text = movie.date
            cell.genreDurationLabel.text = "\(movie.genre)/\(movie.duration)분"
            cell.reservationLabel.text = "\(movie.reservationGrade)위 \(movie.reservationRate)%"
            cell.userRatingLabel.text = "\(movie.userRating)"
            cell.audienceLabel.text = movie.audience.toStringWithComma() ?? "\(movie.audience)"
            setGradeImageView(cell.gradeImageView, grade: movie.grade)
            
            DispatchQueue.global(qos: .background).async {

                guard let imageURL: URL = URL(string: movie.image) else {
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
            
        default:
            return UITableViewCell()
        }
        
    }
}

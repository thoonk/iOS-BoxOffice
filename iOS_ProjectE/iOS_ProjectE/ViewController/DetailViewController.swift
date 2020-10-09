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
    var comments: [Comment?] = []

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
        static let headerCell = "headerCell"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        request()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.movies?.title
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecieveMovieNotification(_:)), name: DidRecieveMovieNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecieveCommentsNotification(_:)), name: DidRecieveCommentsNotification, object: nil)
    }
    
    @objc func didRecieveMovieNotification(_ noti: Notification){
        guard let movie: Movie = noti.userInfo?["movie"] as? Movie else {
            print("noti error")
            return}
        
        self.movie = movie
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func didRecieveCommentsNotification(_ noti: Notification){
        guard let comments: [Comment] = noti.userInfo?["comments"] as? [Comment] else{
            print("comment error")
            return
        }
        self.comments = comments
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func request(){
        guard let movies = movies else{
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        requestMovieDetail(movies.id)
        dispatchGroup.leave()
        
        dispatchGroup.enter()
        requestMovieComments(movies.id)
        dispatchGroup.leave()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == TableViewSection.comment ? comments.count : 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == TableViewSection.info ? 280 : UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == TableViewSection.info ? CGFloat.leastNormalMagnitude : 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movie = movie else{
            return UITableViewCell()
        }
        switch indexPath.section{
        // 정보
        case TableViewSection.info:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.infoCell, for: indexPath) as? InfoTableViewCell else {
                return UITableViewCell()
                
            }
            cell.mappingData(movie)
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
        // 줄거리
        case TableViewSection.synopsis:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.synopsisCell, for: indexPath) as? SynopsisTableViewCell else {
                return UITableViewCell()
            }
            
            cell.synopsisLabel.text = movie.synopsis
            return cell
        // 감독/연출
        case TableViewSection.directorActor:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.directorActorCell, for: indexPath) as? DirectorActorTableViewCell else{
                return UITableViewCell()
            }
            
            cell.directorLabel.text = movie.director
            cell.actorLabel.text = movie.actor
            
            return cell
        // 한줄평
        case TableViewSection.comment:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.commentCell, for: indexPath) as? CommentTableViewCell, let comment = self.comments[indexPath.row] else{
                print("no commentCell")
                return UITableViewCell()
            }
            
            cell.mappingData(comment)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 50))
        let button = UIButton(frame: CGRect(x: tableView.frame.size.width - 30, y: 20, width: 20, height: 20))
        
        switch section{
        case TableViewSection.synopsis:
            label.text = "줄거리"
            button.isHidden = true
        case TableViewSection.directorActor:
            label.text = "감독/출연"
            button.isHidden = true
        case TableViewSection.comment:
            label.text = "한줄평"
            button.setImage(UIImage(named: "btn_compose"), for: .normal)
            button.isHidden = false
        
        default:
            return nil
        }
        view.addSubview(label)
        view.addSubview(button)
        
        return view
    }
}

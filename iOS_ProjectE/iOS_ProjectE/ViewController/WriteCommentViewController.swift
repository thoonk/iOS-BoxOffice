//
//  WriteCommentViewController.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/12.
//

import UIKit

class WriteCommentViewController: MovieViewController {
    
    var movie: Movie?
    private let textPlaceHolder = "한줄평을 작성해주세요"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradeImageView: UIImageView!
    @IBOutlet weak var writerTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!{
        didSet{
            contentsTextView.text = textPlaceHolder
            contentsTextView.textColor = UIColor.placeholderText
            contentsTextView.layer.borderWidth = 1.0
            contentsTextView.layer.borderColor = UIColor.red.cgColor
            contentsTextView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var starRatingView: StarRatingView!{
        didSet{
            starRatingView.isEditable = true
            starRatingView.maxRating = 10
            starRatingView.emptyImage = UIImage(named: "ic_star_large")
            starRatingView.halfImage = UIImage(named: "ic_star_large_half")
            starRatingView.fullImage = UIImage(named: "ic_star_large_full")
            starRatingView.delegate = self
        }
    }
    @IBOutlet weak var ratingLabel: UILabel!{
        didSet{
            ratingLabel.text = "0"
        }
    }

    
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorViewAnimating(activityIndicatorView, isStart: false)
        }
    }
    
    @IBAction private func cancelBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func completeBtnTapped(_ sendere: Any){
        if let writer = writerTextField.text, let contents = contentsTextView.text, !writer.isEmpty, !contents.isEmpty {
            postMovieComment()
        } else{
            alert("닉네임, 한줄평, 평점을 모두 입력하세요.")
            return;
        }
    }
    
    @objc private func viewTapped(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "한줄평 작성"
        
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(viewTapGestureRecognizer)
        
        self.contentsTextView.delegate = self
        writerTextField.text = getWriter()
        
        if let movieData = movie{
            titleLabel.text = movieData.title
            setGradeImageView(gradeImageView, grade: movieData.grade)
        }
    }
    
    //MARK: - DataBase
    private func setWriter(_ writer: String){
        if !writer.isEmpty {
            UserDefaults.standard.setValue(writer, forKey: "writer")
        }
    }
    
    private func getWriter() -> String?{
        if let writer = UserDefaults.standard.value(forKey: "writer") as? String {
            return writer
        }
        return nil
    }
    

    private func postMovieComment(){
        guard let id = movie?.id,
              let writer = writerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let contents = contentsTextView.text else{
            return
        }
        
        let rating = 10.0
        setWriter(writer)
        indicatorViewAnimating(activityIndicatorView, isStart: false)
        
        request.postMovieComment(id, writer: writer, contents: contents, rating: rating) { [weak self] (isSuccess, _, error) in
            guard let self = self else { return }
            self.indicatorViewAnimating(self.activityIndicatorView, isStart: false)
            if let error = error {
                self.errorHandler(error)
            }
            if isSuccess {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.errorHandler()
            }
        }
    }
    
}

extension WriteCommentViewController: StarRatingViewDelegate {
    /// starRatingView의 currentRating 값에 따라 라벨에 표시될 값 설정
    func starRatingView(_ ratingView: StarRatingView, isUpdating rating: Double) {
        ratingLabel.text = String(format: "%.f", rating)
    }
}

extension WriteCommentViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textPlaceHolder {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }
}

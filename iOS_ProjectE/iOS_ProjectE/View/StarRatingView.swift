//
//  StarRatingView.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/15.
//

import UIKit

@objc protocol StarRatingViewDelegate {
    @objc optional func starRatingView(_ ratingView: StarRatingView, willBeginUpdating rating: Double)
    @objc optional func starRatingView(_ ratingView: StarRatingView, isUpdating rating: Double)
    @objc optional func starRatingView(_ ratingView: StarRatingView, didEndUpdating rating: Double)
}

@IBDesignable
class StarRatingView: UIView {
    
    var delegate: StarRatingViewDelegate?
    private var imageViews: [UIImageView] = []
    private var starCount: Int = 5
    private var ratio: Double{
        get {
            return maxRating / Double(starCount)
        }
    }
    private var conversedValue: Double {
        get{
            return currentRating / ratio
        }
    }
    
    @objc enum RatingType: Int{
        case half
        case full
    }
    
    @IBInspectable var type: RatingType = .half
    @IBInspectable var isEditable: Bool = true
    
    @IBInspectable var emptyImage: UIImage?{
        willSet{
            removeImageViews()
        }
        didSet{
            updateImageViews()
        }
    }
    @IBInspectable var halfImage: UIImage?{
        willSet{
            removeImageViews()
        }
        didSet{
            updateImageViews()
        }
    }
    @IBInspectable var fullImage: UIImage?{
        willSet{
            removeImageViews()
        }
        didSet{
            updateImageViews()
        }
    }
    @IBInspectable var minRating: Double = 0{
        willSet{
            removeImageViews()
        }
        didSet{
            if minRating < 0{
                minRating = 0
            }
            updateImageViews()
        }
    }
    @IBInspectable var maxRating: Double = 5{
        willSet{
            removeImageViews()
        }
        didSet{
            if maxRating < Double(starCount){
                maxRating = Double(starCount)
            }
            updateImageViews()
        }
    }
    @IBInspectable var currentRating: Double = 0{
        willSet{
            removeImageViews()
        }
        didSet{
            if currentRating < minRating{
                currentRating = minRating
            }else if currentRating > maxRating{
                currentRating = maxRating
            }
            updateImageViews()
        }
    }
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateImageViews()
    }
    /// 기본 초기화 메서드
    required init(frame: CGRect, type: RatingType = .half, isEditable: Bool = true) {
        super.init(frame: frame)
        self.type = type
        self.isEditable = isEditable
        updateImageViews()
    }
    // 스토리보드 에러: IB Designables - Failed to render and update auto layout status, The agent crashed를 피하기 위한 구현
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(frame: CGRect, type: RatingType, isEditable: Bool, minRating: Double, maxRating: Double, currentRating: Double) {
        self.init(frame: frame, type: type, isEditable: isEditable)
        self.minRating = minRating
        self.maxRating = maxRating
        self.currentRating = currentRating
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let emptyImage = emptyImage else {
            return
        }
        let imageWidth = frame.size.width / CGFloat(starCount)
        let imageViewSize = setImageSize(emptyImage, size: CGSize(width: imageWidth, height: frame.size.height))
        let xOffset = (frame.size.width - (imageViewSize.width * CGFloat(starCount))) / CGFloat(starCount - 1)
        for i in 0 ..< starCount {
            let x = i == 0 ? 0 : CGFloat(i) * (xOffset + imageViewSize.width)
            let frame = CGRect(x: x, y: 0, width: imageViewSize.width, height: imageViewSize.height)
            let imageView = imageViews[i]
            imageView.frame = frame
        }
        updateLayout()
    }


    private func updateImageViews(){
        guard imageViews.isEmpty else{
            return
        }
        for _ in 0 ..< starCount{
            let imageView = UIImageView()
            imageView.image = emptyImage
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
            addSubview(imageView)
        }
    }
    
    private func removeImageViews(){
        for i in 0 ..< starCount {
            let imageView = imageViews[i]
            imageView.removeFromSuperview()
        }
        imageViews.removeAll()
    }
    
    /// 별을 채우는 메서드
    private func updateLayout(){
        for i in 0 ..< starCount{
            let imageView = imageViews[i]
            if conversedValue >= Double(i + 1){
                imageView.image = fullImage
            } else if conversedValue > Double(i),
                      conversedValue < Double(i + 1){
                let decimalValue = conversedValue - Double(i)
                if decimalValue < 0.5 {
                    imageView.image = emptyImage
                } else{
                    imageView.image = halfImage
                }
            } else{
                imageView.image = emptyImage
            }
        }
    }
    /// 이미지와 뷰의 비율에 맞게 적절한 사이즈 반환함
    private func setImageSize(_ image: UIImage, size: CGSize) -> CGSize {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = size.width / size.height
        if imageRatio < viewRatio {
            let scale = size.height / image.size.height
            let width = scale * image.size.width
            return CGSize(width: width, height: size.height)
        } else {
            let scale = size.width / image.size.width
            let height = scale * image.size.height
            return CGSize(width: size.width, height: height)
        }
    }
    
    /// 터치의 위치에 따라 CurrentRating 값 변경
    private func updateCurrentRating(_ touch: UITouch){
        guard isEditable else{
            return
        }
        delegate?.starRatingView?(self, willBeginUpdating: currentRating)
        let touchLocation = touch.location(in: self)
        var newRating: Double = 0
        
        for i in stride(from: starCount-1, through: 0, by: -1){
            let imageView = imageViews[i]
            if touchLocation.x <= imageView.frame.origin.x {
                continue
            }
            
            let newLocation = imageView.convert(touchLocation, to: self)
            if imageView.point(inside: newLocation, with: nil),
               type != .full{
                let decimalValue = Double(newLocation.x / imageView.frame.width)
                if type == .half{
                    newRating = Double(i) + (decimalValue > 0.75 ? 1 : (decimalValue > 0.25 ? 0.5 : 0))
                } else{
                    newRating = Double(i) + decimalValue
                }
            } else{
                newRating = Double(i) + 1
            }
            break
        }
        currentRating = newRating * ratio
        delegate?.starRatingView?(self, isUpdating: currentRating)
    }
    
    //MARK: - Touch Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateCurrentRating(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateCurrentRating(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.starRatingView?(self, didEndUpdating: currentRating)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.starRatingView?(self, didEndUpdating: currentRating)
    }
}

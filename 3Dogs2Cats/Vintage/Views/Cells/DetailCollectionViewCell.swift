import UIKit
import Nuke

protocol DetailCollectionViewCellDelegate: AnyObject {
  func didTapCancelButton()
  func didTapSharingButton(for cell: UICollectionViewCell)
  func didSaveVintageToFavorite(for cell: DetailCollectionViewCell)
  func didTapApplyFilterFor(cell: DetailCollectionViewCell)
}

class DetailCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  enum Color {
    static let link = "link"
    static let blackWhite = "BlackWhite"
    static let xmark = "xmark"
    static let star = "star"
    static let lasso = "lasso"
  }
  
  weak var delegate: DetailCollectionViewCellDelegate?
  
  private let view : UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .black
    
    return view
  }()
  
  lazy var vintageImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    imageView.clipsToBounds = true
    imageView.isUserInteractionEnabled = true
    
    return imageView
  }()
  
  lazy var cancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    button.layer.cornerRadius = button.frame.size.width / 2
    button.clipsToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .systemGray6
    button.layer.masksToBounds = true
    button.setImage(UIImage(systemName: Color.xmark), for: .normal)
    button.tintColor = UIColor(named: Color.blackWhite)
    button.addTarget(self, action: #selector(cancelScreen), for: .touchUpInside)
    
    return button
  }()
  
  lazy var imageSharingButton: UIButton = {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    button.layer.cornerRadius = button.frame.size.width / 2
    button.clipsToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .systemGray6
    button.layer.masksToBounds = true
    button.setImage(UIImage(systemName: Color.link), for: .normal)
    button.tintColor = UIColor(named: Color.blackWhite)
    button.addTarget(self, action: #selector(showSharingActivityView), for: .touchUpInside)
    
    return button
  }()
  
  lazy var favoriteButton: UIButton = {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    button.layer.cornerRadius = button.frame.size.width / 2
    button.clipsToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .systemGray6
    button.layer.masksToBounds = true
    button.setImage(UIImage(systemName: Color.star), for: .normal)
    button.tintColor = UIColor(named: Color.blackWhite)
    button.addTarget(self, action: #selector(addFavorite), for: .touchUpInside)
    
    return button
  }()
  
  lazy var applyFilterButton: UIButton = {
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    button.layer.cornerRadius = button.frame.size.width / 2
    button.clipsToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .systemGray6
    button.layer.masksToBounds = true
    button.setImage(UIImage(systemName:Color.lasso), for: .normal)
    button.tintColor = UIColor(named: Color.blackWhite)
    button.addTarget(self, action: #selector(showAlertFilter), for: .touchUpInside)
    
    return button
  }()
  
  @objc func addFavorite() {
    delegate?.didSaveVintageToFavorite(for: self)
  }
  
  @objc func showAlertFilter() {
    delegate?.didTapApplyFilterFor(cell: self)
  }
  
  @objc func cancelScreen() {
    delegate?.didTapCancelButton()
  }
  
  @objc func showSharingActivityView() {
    delegate?.didTapSharingButton(for: self)
  }
  
  let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
  
  @objc func swipeDown(sender: UISwipeGestureRecognizer) {
    if sender.direction == .down {
      delegate?.didTapCancelButton()
    }
  }
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(vintageImageView)
    addSubview(cancelButton)
    addSubview(imageSharingButton)
    addSubview(favoriteButton)
    addSubview(applyFilterButton)
    
    NSLayoutConstraint.activate([
      
      vintageImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      vintageImageView.trailingAnchor.constraint(equalTo:trailingAnchor),
      vintageImageView.topAnchor.constraint(equalTo:topAnchor),
      vintageImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      vintageImageView.heightAnchor.constraint(equalToConstant: bounds.height),
      vintageImageView.widthAnchor.constraint(equalToConstant: bounds.width),
      
      cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 16),
      cancelButton.topAnchor.constraint(equalTo: topAnchor,constant: 32),
      cancelButton.heightAnchor.constraint(equalToConstant: 50),
      cancelButton.widthAnchor.constraint(equalToConstant: 50),
      
      imageSharingButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -16),
      imageSharingButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -32),
      imageSharingButton.heightAnchor.constraint(equalToConstant: 50),
      imageSharingButton.widthAnchor.constraint(equalToConstant: 50),
      
      favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -16),
      favoriteButton.topAnchor.constraint(equalTo: topAnchor,constant: 32),
      favoriteButton.heightAnchor.constraint(equalToConstant: 50),
      favoriteButton.widthAnchor.constraint(equalToConstant: 50),
      
      applyFilterButton.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 16),
      applyFilterButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -32),
      applyFilterButton.heightAnchor.constraint(equalToConstant: 50),
      applyFilterButton.widthAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

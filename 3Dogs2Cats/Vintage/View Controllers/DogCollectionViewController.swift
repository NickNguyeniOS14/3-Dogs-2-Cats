import UIKit
import Nuke

class DogCollectionViewController: UICollectionViewController {
  
  // MARK:- Properties
  
  private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  private let itemsPerRow: CGFloat = 3
  private let topRefreshcontrol = UIRefreshControl()
  private let footerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
  var page = 1
  var isLoadingMorePictures = false
  var dogSearchString = "dog"
  
  var dogs = [Animal]() {
    didSet {
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  
  // MARK: - View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(
      DogFooterView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: "Footer"
    )
    
    (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
    
    loadPictures()
    topRefreshcontrol.addTarget(self, action: #selector(refreshToprefreshControl), for: .valueChanged)
    topRefreshcontrol.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    collectionView.refreshControl = topRefreshcontrol
    
  }
  
  @objc func refreshToprefreshControl() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.topRefreshcontrol.endRefreshing()
    }
  }
  
  func loadPictures() {
    
    isLoadingMorePictures = true
    
    NetworkManager.shared.getAnimals(searchString: dogSearchString, page: page) { (result) in
      switch result {
        case .success(let dogs):
          
          self.dogs += dogs
          
        case .failure(let error):
          print(error.localizedDescription)
      }
      self.isLoadingMorePictures = false
    }
  }
  
  // MARK: - Collection View Data Source
  
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int
  ) -> Int {
    
    return dogs.count
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VintageCell", for: indexPath) as! DogCell
    
    let imageURL = dogs[indexPath.item].src.portrait
    let url = URL(string: imageURL)!
    
    let options = ImageLoadingOptions(
      placeholder: UIImage(named: "placeholder"),
      transition: .fadeIn(duration: 0.4)
    )
    Nuke.loadImage(with: url, options: options, into: cell.dogImageView)
    
    return cell
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    
    let destVC = DetailCollectionViewController(collectionViewLayout: layout)
    destVC.dataSource = dogs
    destVC.selectedIndexPath = indexPath
    destVC.searchStringForDetail = dogSearchString
    
    destVC.modalPresentationStyle = .fullScreen
    present(destVC, animated: true, completion: nil)
  }
  
  
  // MARK: - Footer view
  
  override func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    if indexPath.item == dogs.count - 1 {  //numberofitem count
      footerView.startAnimating()
      guard !isLoadingMorePictures else { return }
      page += 1
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
        self.loadPictures()
      }
    }
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionFooter {
      let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
      footer.addSubview(footerView)
      footerView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
      return footer
    }
    return UICollectionReusableView()
  }
}

// MARK:- UICollectionViewDelegateFlowLayout 3 grids

extension DogCollectionViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    
    let screenWidth = UIScreen.main.bounds.width
    let scaleFactor = (screenWidth / 2)
    
    return CGSize(width: scaleFactor, height: scaleFactor + scaleFactor)
  }
  
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 0
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 0
  }
}


import UIKit
import Nuke

class CatCollectionViewController: UICollectionViewController {
  
  private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  private let itemsPerRow: CGFloat = 3
  private var page = 1
  private var isLoadingMorePictures = false
  private let topRefreshcontrol = UIRefreshControl()
  private var catSearchString = "cat"
  private let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
  
  
  private var cats = [Animal]() {
    didSet {
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  
  // MARK:- View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(CatFooterView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                            withReuseIdentifier: "ClassicFooter")
    
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
  
  private func loadPictures() {
    
    isLoadingMorePictures = true
    
    NetworkManager.shared.getAnimals(searchString: catSearchString, page: page) { (result) in
      switch result {
        case .success(let cats):
          self.cats += cats
        case .failure(let error):
          print(error.localizedDescription)
      }
      self.isLoadingMorePictures = false
    }
  }
  
  // MARK: - Collection View Data Source
  
  override func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    
    return cats.count
  }
  
  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassicVintageCell", for: indexPath) as! CatCell
    
    let imageURL = cats[indexPath.item].src.portrait
    let url = URL(string: imageURL)!
    
    let options = ImageLoadingOptions(
      placeholder: UIImage(named: "placeholder"),
      transition: .fadeIn(duration: 0.4)
    )
    Nuke.loadImage(with: url, options: options, into: cell.classicImageView)
    
    return cell
  }
  override func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    let destVC = DetailCollectionViewController(collectionViewLayout: layout)
    destVC.dataSource = cats
    destVC.selectedIndexPath = indexPath
    destVC.searchStringForDetail = catSearchString
    destVC.modalPresentationStyle = .fullScreen
    present(destVC, animated: true, completion: nil)
  }
  
  
  // MARK: - Footer view
  
  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath
  ) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionFooter {
      let footer = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: "ClassicFooter",
        for: indexPath
      )
      footer.addSubview(spinner)
      spinner.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
      return footer
    }
    return UICollectionReusableView()
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath
  ) {
    if indexPath.item == cats.count - 1 {  //numberofitem count
      spinner.startAnimating()
      guard !isLoadingMorePictures else { return }
      page += 1
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
        self.loadPictures()
      }
    }
  }
}

// MARK:- UICollectionViewDelegateFlowLayout 3 Grids

extension CatCollectionViewController: UICollectionViewDelegateFlowLayout {
  
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

import UIKit
import Nuke

class FavoriteAnimalCollectionViewController: UICollectionViewController {

  private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  private let itemsPerRow: CGFloat = 3
  let topRefreshcontrol = UIRefreshControl()
  var classicVintageSearchString = "vintage black and white"
  private let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .trash,
      target: self, action: #selector(deleteAllData)
    )

    topRefreshcontrol.addTarget(self, action: #selector(refreshToprefreshControl), for: .valueChanged)
    topRefreshcontrol.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    collectionView.refreshControl = topRefreshcontrol
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadFavoritesQuotes()
    collectionView.reloadData()
  }

  func loadFavoritesQuotes()  {

    guard let persister = Persister.shared else { return }
    do {
      DetailCollectionViewController.favoriteVingates = try persister.fetch()
    } catch {
      NSLog("Error loading from persistence!: \(error)")
    }
  }

  @objc func refreshToprefreshControl() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.topRefreshcontrol.endRefreshing()
    }
  }

  @objc func deleteAllData() {
    let alertController = UIAlertController(
      title: "Delete all of saved photos?",
      message: "This will delete all of your favorite photos.",
      preferredStyle: .alert
    )
    alertController.addAction(UIAlertAction(
                                title: "OK",
                                style: .destructive,
                                handler: { (action) in
      DetailCollectionViewController.favoriteVingates = []
      Persister.shared?.save(DetailCollectionViewController.favoriteVingates)
      self.collectionView.reloadData()
    })
    )
    alertController.addAction(UIAlertAction(
                                title: "Cancel",
                                style: .cancel,
                                handler: nil)
    )
    present(alertController, animated: true, completion: nil)

  }

  // MARK: - Collection View Data Source

  override func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    if DetailCollectionViewController.favoriteVingates.count == 0 {
      self.collectionView.setEmptyMessage("No favorite photos added")
    } else {
      self.collectionView.restore()
    }
    return DetailCollectionViewController.favoriteVingates.count
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "FavoriteCell",
      for: indexPath
    ) as! FavoriteCell

    let imageData = DetailCollectionViewController.favoriteVingates[indexPath.item]

    DispatchQueue.global().async {
      let image = UIImage(data: imageData)
      DispatchQueue.main.async {
        cell.cellImageview.image = image
      }
    }

    return cell
  }
  override func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    let selectedVintage = DetailCollectionViewController.favoriteVingates[indexPath.item]
    print(selectedVintage)

  }
}

// MARK:- UICollectionViewDelegateFlowLayout display 3 grids

extension FavoriteAnimalCollectionViewController: UICollectionViewDelegateFlowLayout {

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
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 0
  }
}

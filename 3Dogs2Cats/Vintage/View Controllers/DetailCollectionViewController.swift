import UIKit
import Nuke
import JGProgressHUD
import SafariServices
import CoreImage.CIFilterBuiltins

class DetailCollectionViewController: UICollectionViewController {

  // MARK: - Properties

  static var favoriteVingates: [Data] = []

  var dataSource: [Animal] = [] {
    didSet {
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  var selectedIndexPath: IndexPath?
  var page = 1
  var showSelectedImageForIndexPath = false
  var isLoadingMorePictures = false
  var searchStringForDetail: String = ""
  var isTap: Bool = false
  var outputFilteredImage: UIImage?
  var hasFilter = false
  let context = CIContext(options: nil)

  override var prefersStatusBarHidden: Bool {
    return true
  }

  // MARK:- View Life Cycle

  override func viewDidLoad() {
    collectionView.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: "DetailCell")
    view.backgroundColor = .white
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
  }

  func loadVintages() {

    isLoadingMorePictures = true

    NetworkManager.shared.getAnimals(searchString: searchStringForDetail, page: page) { (result) in
      switch result {
        case .success(let vintages):

          self.dataSource += vintages

        case .failure(let error):
          print(error.localizedDescription)
      }
      self.isLoadingMorePictures = false
    }
  }

  @objc func swipeDown(_ sender: UISwipeGestureRecognizer) {

    dismiss(animated: true, completion: nil)
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath) {

    if !showSelectedImageForIndexPath {
      //set the row and section you need.
      collectionView.scrollToItem(at: selectedIndexPath!, at: .right, animated: false)
      showSelectedImageForIndexPath = true
    }

    if indexPath.item == dataSource.count - 1 {  //numberofitem count
      //      footerView.startAnimating()
      guard !isLoadingMorePictures else { return }
      page += 1
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
        self.loadVintages()

      }
    }
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }


  override func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath) {
    isTap.toggle()
    print("IS TAP VALUE IS \(isTap)")

    for (index, _) in dataSource.enumerated() {
      let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? DetailCollectionViewCell

      UIView.animate(withDuration: 0.2) {
        //
        cell?.cancelButton.alpha = self.isTap ? 0.5 : 1.0
        cell?.imageSharingButton.alpha = self.isTap ? 0.5 : 1.0
        cell?.favoriteButton.alpha = self.isTap ? 0.5 : 1.0
        cell?.applyFilterButton.alpha = self.isTap ? 0.5 : 1.0
      } completion: {  (completed) in
        cell?.cancelButton.isHidden = self.isTap
        cell?.imageSharingButton.isHidden = self.isTap
        cell?.favoriteButton.isHidden = self.isTap
        cell?.applyFilterButton.isHidden = self.isTap
      }
    }
  }

  override func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell",
                                                  for: indexPath) as! DetailCollectionViewCell

    cell.delegate = self

    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))

    swipeGesture.direction = [.down,.up]

    cell.addGestureRecognizer(swipeGesture)

    let imageURL = dataSource[indexPath.item].src.portrait

    let url = URL(string: imageURL)!

    let options = ImageLoadingOptions(
      placeholder: UIImage(named: "placeholder"),
      transition: .fadeIn(duration: 0.4))

    Nuke.loadImage(with: url, options: options, into: cell.vintageImageView)

    return cell

  }

  private func filterComicImage(_ image: UIImage) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    let ciImage = CIImage(cgImage: cgImage)
    let filter = CIFilter.comicEffect()

    filter.setValue(ciImage, forKey: kCIInputImageKey)

    guard let outputCIImage = filter.outputImage else { return nil }

    guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size) ) else { return nil }

    return UIImage(cgImage: outputCGImage)
  }
}

extension DetailCollectionViewController: DetailCollectionViewCellDelegate {
  func didTapApplyFilterFor(cell: DetailCollectionViewCell) {

    let originalUIImage = cell.vintageImageView.image!

    let alert = UIAlertController(title: "Apply filter for photo", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Sepia", style: .default, handler: { (action) in


      guard let currentImage = cell.vintageImageView.image,
            let ciImage = CIImage(image: currentImage) else {
        return
      }

      DispatchQueue.global().async {
        let filter = CIFilter(name: "CISepiaTone")

        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        filter?.setValue(0.8, forKey: kCIInputIntensityKey)

        guard let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage else {
          return
        }
        guard let cgImage = self.context.createCGImage(filteredImage, from: filteredImage.extent) else {
          return
        }
        self.outputFilteredImage = UIImage(cgImage: cgImage)

        DispatchQueue.main.async {
          cell.vintageImageView.image = self.outputFilteredImage
          self.hasFilter = true
        }
      }
    }))
    alert.addAction(UIAlertAction(title: "Comic", style: .default, handler: { (action) in

      let cgImage = cell.vintageImageView.image?.cgImage!
      let ciImage = CIImage(cgImage: cgImage!)
      let filter = CIFilter.comicEffect()

      filter.setValue(ciImage, forKey: kCIInputImageKey)
      let outputCIImage = filter.outputImage!
      let output = self.context.createCGImage(outputCIImage, from: outputCIImage.extent)

      DispatchQueue.main.async {
        self.hasFilter = true
        self.outputFilteredImage = UIImage(cgImage: output!)
        cell.vintageImageView.image = self.outputFilteredImage

      }
    }))

    alert.addAction(UIAlertAction(title: "Original", style: .default, handler: { (action) in
      //
      cell.vintageImageView.image = originalUIImage
      self.hasFilter = false
      self.collectionView.reloadData()
    }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    present(alert, animated: true, completion: nil)
  }


  func didSaveVintageToFavorite(for cell: DetailCollectionViewCell) {

    let imageData = cell.vintageImageView.image!.pngData()!
    DetailCollectionViewController.favoriteVingates.append(imageData)
    Persister.shared?.save(DetailCollectionViewController.favoriteVingates)
    let hud = JGProgressHUD()
    hud.style = .dark
    hud.textLabel.text = "Photo Added to Favorites"
    let indicatorView = JGProgressHUDSuccessIndicatorView()
    hud.indicatorView = indicatorView
    hud.show(in: self.view)
    hud.dismiss(afterDelay: 0.6)

  }

  func didTapSharingButton(for cell: UICollectionViewCell) {
    let indexPath = collectionView.indexPath(for: cell)!
    let urlString = dataSource[indexPath.item].src.portrait
    let url = URL(string: urlString)!

    DispatchQueue.global().async {
      if let data = try? Data(contentsOf:url) {
        guard let image = UIImage(data: data) else { return }
        DispatchQueue.main.async {

          let activityViewController = UIActivityViewController(activityItems: [self.hasFilter ? self.outputFilteredImage! : image], applicationActivities: nil)

          self.present(activityViewController, animated: true, completion: {

          })
          activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {  // User canceled
              return
            }
            // User completed activity
            let hud = JGProgressHUD()
            hud.style = .dark
            hud.textLabel.text = "Photo Saved"
            let indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.indicatorView = indicatorView
            hud.show(in: self.view)

            hud.dismiss(afterDelay: 0.8)
            print("COMPLETED")
          }
        }
      }
    }
  }
  
  func didTapCancelButton() {
    dismiss(animated: true, completion: nil)
  }
}

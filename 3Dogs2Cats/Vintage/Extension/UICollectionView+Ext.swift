import UIKit

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor(named: "BlackWhite")
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Copperplate", size: 26)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UICollectionViewController {
    var layout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        return layout
    }
}

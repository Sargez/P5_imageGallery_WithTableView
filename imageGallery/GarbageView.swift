//
//  GabargeView.swift
//  imageGallery
//
//  Created by 1C on 20/07/2022.
//

import UIKit

class GarbageView: UIView, UIDropInteractionDelegate {

    // MARK: Initialization & layout
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let button = garbageButton {
            button.frame = CGRect(x: bounds.width - 100, y: 0, width: 100, height: bounds.height)
        }
        
    }
    
    // MARK: - Drop delegate view method's
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return ((session.localDragSession?.localContext as? UICollectionView) != nil) ? UIDropProposal(operation: .copy) : UIDropProposal(operation: .forbidden)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        session.loadObjects(ofClass: NSURL.self) { providers in
            
            if let collectionView = session.localDragSession?.localContext as? UICollectionView,
               let items = session.localDragSession?.items,
               let sourceItems = (collectionView.dataSource as? imageGalleryViewController)?.imageGallery {
                
                var indexPath: [IndexPath] = []
                var index: [Int] = []
                
                items.forEach {
                    if let path = $0.localObject as? IndexPath {
                        indexPath += [path]
                        index += [path.item]
                    }
                }
                
                collectionView.performBatchUpdates {
                    collectionView.deleteItems(at: indexPath)
                    sourceItems.images = sourceItems.images.enumerated().filter{!index.contains($0.offset)}.map{$0.element}
                }
                
            }
            
        }
        
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, previewForDropping item: UIDragItem, withDefault defaultPreview: UITargetedDragPreview) -> UITargetedDragPreview? {
        
        if let button = garbageButton {
            let dragPreviewTarget = UIDragPreviewTarget(container: button,
                                                        center: CGPoint(x: button.bounds.width/2, y: button.bounds.height/2),
                                                        transform: CGAffineTransform(scaleX: 0.1, y: 0.1))
            
            return defaultPreview.retargetedPreview(with: dragPreviewTarget)
        } else {
            return nil
        }
        
    }
    
    // MARK: - Private implementation
    
    private func setup() {
        
        addInteraction(UIDropInteraction(delegate: self))
        
        backgroundColor = .clear
        
        let button = UIButton()
        let trashImage = UIImage().imageFromBarButtonCustom()
        button.setImage(trashImage, for: .normal)
        addSubview(button)
        
    }
    
    private var garbageButton: UIButton? {
        subviews.first as? UIButton
    }
}

extension UIImage {
    func imageFromBarButtonCustom() -> UIImage? {
        return UIImage(systemName: "trash")
    }
}

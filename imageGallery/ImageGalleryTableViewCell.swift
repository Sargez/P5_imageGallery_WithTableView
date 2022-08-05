//
//  ImageGalleryTableViewCell.swift
//  imageGallery
//
//  Created by 1C on 13/07/2022.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell, UITextFieldDelegate {

    // MARK: - Public API
    var resignHandler: (() -> Void)?
    
    // MARK: - Outlets
        
    @IBOutlet weak var textField: UITextField! {
        didSet{
            textField.delegate = self
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(startEditTextFieldInCell(_:)))
            tap.numberOfTapsRequired = 2
            addGestureRecognizer(tap)
            
        }
    }
 
    // MARK: - Text field delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        resignHandler?()
        
    }
    
    // MARK: - Gesture recognizers implementation
    
    @objc private func startEditTextFieldInCell(_ recognizer: UITapGestureRecognizer) {
        
        switch recognizer.state {
        case .ended:
            textField.isEnabled = true
            textField.becomeFirstResponder()
        default:
            break
        }
    
    }
    
}

//
//  TextViewController.swift
//  UITextViewWithImage
//
//  Created by Emre on 28.04.2022.
//

import UIKit

class TextViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var customTextView: UITextView = {
        
        let customText = UITextView()
        
        customText.backgroundColor = .clear
        customText.textAlignment = .left
        customText.textColor = UIColor.lightGray
        customText.font = UIFont(name: "AvenirNext-Italic", size: 16)
        customText.layer.borderWidth = 0.8
        customText.layer.cornerRadius = 7.0
        customText.layer.borderColor = UIColor.orange.cgColor
        
        return customText
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 23/255, green: 30/255, blue: 48/255, alpha: 1)
        
        customTextView.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        setTextViewAnchors()
        setKeyboardBar()
    }
    
    //MARK: - Keyboard Bar Configuration
    
    func setKeyboardBar() {
        
        let bar = UIToolbar()
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let photoLabel = UIBarButtonItem(title: "Add Photo", style: .plain, target: self, action: #selector(imageTapped))
        let dismissLabel = UIBarButtonItem(title: "Dismiss Keyboard", style: .plain, target: self, action: #selector(dismissedKeyboard))
        
        photoLabel.tintColor = .yellow
        photoLabel.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBoldItalic", size: 11)!] , for: .normal)
        
        dismissLabel.tintColor = .yellow
        dismissLabel.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBoldItalic", size: 11)!] , for: .normal)
        
        bar.items = [photoLabel, flex, dismissLabel]
        bar.barTintColor = .darkGray
        bar.sizeToFit()
        
        customTextView.inputAccessoryView = bar
        
    }
    
    @objc func dismissedKeyboard() {
        
        view.endEditing(true)
    }
    
    //MARK: - Image TextAttachment
        
    @objc func imageTapped() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info [UIImagePickerController.InfoKey.editedImage] as! UIImage
        image.jpegData(compressionQuality: 0.2)
        
        let attachment = NSTextAttachment()
        attachment.image = image
        
        let newImageWidth = (customTextView.bounds.size.width - 10)
        let scale = newImageWidth / image.size.width
        let newImageHeight = (image.size.height * scale)
        
        attachment.bounds = CGRect(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
        
        let attstring = NSAttributedString(attachment: attachment)
        
        customTextView.textStorage.insert(attstring, at: customTextView.selectedRange.location)
        customTextView.font = UIFont(name: "AvenirNext-Italic", size: 16)
        customTextView.textColor = .white
        customTextView.textAlignment = .left
        
        picker.dismiss(animated: true, completion: nil)
        
        let myString = "\n"
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        let combination = NSMutableAttributedString()
               
        combination.append(customTextView.attributedText)
        combination.append(myAttrString)
        customTextView.attributedText = combination
        customTextView.font = UIFont(name: "AvenirNext-Italic", size: 16)
    }

    
    //MARK: - Get Images
    
    func getImagesFromWritePost() -> (images: [UIImage], locations: [Int], imageDataArray: [Data]) {
        
        var images = [UIImage]()
        var locations = [Int]()
        var imageDataArray = [Data]()
        
        customTextView.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, customTextView.attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (value, range, stop) in
            
            guard let attachment = value as? NSTextAttachment else { return }
            
            if let image = attachment.image {
                
                images.append(image)
                imageDataArray.append(image.jpegData(compressionQuality: 0.4)!)
                locations.append(range.location)
                
            } else if let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) {
                
                images.append(image)
                imageDataArray.append(image.jpegData(compressionQuality: 0.4)!)
                locations.append(range.location)
            }
        }
       
        return (images, locations, imageDataArray)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK - Keyboard Adjustment
    
    @objc func adjustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            customTextView.contentInset = .zero
            
        } else {
            
            customTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        customTextView.scrollIndicatorInsets = customTextView.contentInset
        
        let selectedRange = customTextView.selectedRange
        customTextView.scrollRangeToVisible(selectedRange)
    }

    //MARK: - TextView Constraints
    
    fileprivate func setTextViewAnchors() {
        
        view.addSubview(customTextView)
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        customTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4.0).isActive = true
        customTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4.0).isActive = true
        customTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -4.0).isActive = true
        customTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4.0).isActive = true
    }


}


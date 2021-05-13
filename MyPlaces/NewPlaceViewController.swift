//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Aksilont on 06.05.2021.
//

import UIKit
import PhotosUI

class NewPlaceViewController: UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    var imageIsChanged: Bool = false
    var currentPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setupEditScreen()
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowMap",
              let mapVC = segue.destination as? MapViewController
        else { return }
        mapVC.place.name = placeName.text!
        mapVC.place.location = placeLocation.text!
        mapVC.place.type = placeType.text!
        mapVC.place.imageData = placeImage.image?.pngData()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(systemName: "camera")
            let photoIcon = UIImage(systemName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                               message: nil,
                                               preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker()
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.choosePhoto()
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            view.endEditing(true)
        }
    }
    
    func savePlace() {
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        
        if currentPlace != nil {
            do {
                try realm.write {
                    currentPlace?.name = newPlace.name
                    currentPlace?.location = newPlace.location
                    currentPlace?.type = newPlace.type
                    currentPlace?.imageData = newPlace.imageData
                    currentPlace?.rating = newPlace.rating
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        guard let currentPlace = currentPlace else { return }
        guard let data = currentPlace.imageData, let image = UIImage(data: data) else { return }
        
        placeName.text = currentPlace.name
        placeLocation.text = currentPlace.location
        placeType.text = currentPlace.type
        placeImage.image = image
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        ratingControl.rating = Int(currentPlace.rating)
        
        imageIsChanged = true
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = placeName.text
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        saveButton.isEnabled = !(placeName.text?.isEmpty ?? true)
    }
    
}

// MARK: - Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType = .camera) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
    
}

// MARK: - PHPickerViewControllerDelegate

extension NewPlaceViewController: PHPickerViewControllerDelegate {
    
    func choosePhoto() {
        var config = PHPickerConfiguration()
        config.filter = .images

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        
        itemProviders.forEach { item in
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { object, _ in
                    DispatchQueue.main.async {
                        if let image = object as? UIImage {
                            self.placeImage.image = image
                            self.placeImage.contentMode = .scaleAspectFill
                            self.placeImage.clipsToBounds = true
                            self.imageIsChanged = true
                        }
                    }
                }
            }
        }
    }
    
}

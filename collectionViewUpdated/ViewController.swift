//
//  ViewController.swift
//  collectionViewUpdated
//
//  Created by HChlebek on 11/7/16.
//  Copyright © 2016 HChlebek. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    var people = [Person]()
    let picker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        // pulls out user data from disk
        if let savedPeople = defaults.object(forKey: "people") as? Data
        {
            people = NSKeyedUnarchiver.unarchiveObject(with: savedPeople) as! [Person]
            
            // converts data back into an object.
        }
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        flowLayout.minimumInteritemSpacing = screenWidth/3 - 140
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! PersonCell
        
        let person = people[indexPath.item]
        
        cell.myLabel.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.myImage.image = UIImage(contentsOfFile: path.path)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let questionController = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .alert)
        
        let person = people[indexPath.item]
        
        questionController.addAction(UIAlertAction(title: "Rename Person", style: .default, handler: { (action:UIAlertAction!) -> Void in
            
            let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            ac.addTextField(configurationHandler: nil)
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] _ in
                let newName = ac.textFields![0]
                person.name = newName.text!
                
                self.myCollectionView?.reloadData()
                self.save()
            })
            self.present(ac, animated: true, completion: nil)
        }))
        
        questionController.addAction(UIAlertAction(title: "Delete Person", style: .default, handler: { (action:UIAlertAction!) -> Void in
            self.people.remove(at: indexPath.item)
            self.myCollectionView.deleteItems(at: [indexPath as IndexPath])
            self.myCollectionView.reloadData()
            self.save()
        }))
        
        present(questionController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let items = people[sourceIndexPath.row]
        people.remove(at: sourceIndexPath.row)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func addNewPerson()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
        picker.sourceType = UIImagePickerControllerSourceType.camera
        present(picker, animated: true, completion: nil)
        }

        else
        {
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any)
    {
        addNewPerson()
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80)
        {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        myCollectionView?.reloadData()
        save()
        
        dismiss(animated: true)
    }
    
    func handleGesture(gesture: UILongPressGestureRecognizer)
    {
        switch(gesture.state)
        {
        case UIGestureRecognizerState.began: guard let selectedIndexPath = self.myCollectionView.indexPathForItem(at: gesture.location(in: self.myCollectionView))
        else
        {
          break
        }
            myCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed: myCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended: myCollectionView.endInteractiveMovement()
        default: myCollectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func longPressRecognised(_ sender: Any)
    {
        handleGesture(gesture: longPress)
    }
    
    @IBAction func editButtonPressed(_ sender: Any)
    {
    }
    
    func save()
    {
        // NSKeyArchiver converts our array into data object.
        
        let savedData = NSKeyedArchiver.archivedData(withRootObject: people)
        
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "people")
    }


}


//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Russelle Pineda on 3/9/19.
//  Copyright © 2019 Russelle Pineda. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

//need UIImagePickerControllerDelegate and UINavigationControllerDelegate
class CameraViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onFeedBarButton(_ sender: Any) {
        
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        //all object of all type is PFObject
        
        //let pet = PFObject(className: "Pets")
        let post = PFObject(className: "Posts")
        
        //dictionary
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        //photo. Photos are binary objects. stored in URL not directly in row so need to use pffile object
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!) //create new parse file
        
        post["image"] = file //this column will have URL for photos
        
        
        post.saveInBackground { (success, error) in
            if  success {
            self.dismiss(animated: true, completion: nil)
                print("Saved!")
            }
            else {
                print("Error!")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self //when user done taking photo,call back that has photo
        picker.allowsEditing = true // allows editing in a 2nd screen
        
        //check if camera is available or app crashes
        //swift enums you can start with dot(.). Example ".camera"
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera //if cam available, use cam
        }
        else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
}

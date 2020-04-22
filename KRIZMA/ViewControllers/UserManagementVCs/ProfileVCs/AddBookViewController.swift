//
//  AddBookViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 12/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import AlamofireImage
import MBProgressHUD

class AddBookViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet var skipBtn:UIButton!
    @IBOutlet var cameraBtn:UIButton!
    
    @IBOutlet var imgView:UIImageView!
    @IBOutlet var typeImgView:UIImageView!
    @IBOutlet var txtName:UITextField!
    @IBOutlet var txtLanguage:UITextField!
    @IBOutlet var txtAuthor:UITextField!
    let imagePicker = UIImagePickerController()

    var type = "new"
    var photoFlag = false
    
    override func viewDidLoad()
    {
        self.imagePicker.delegate = self
        cameraBtn.layer.cornerRadius = 38
        cameraBtn.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    @IBAction func skipBtnAction(_ button:UIButton)
    {
        let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController"))as! SearchViewController
        self.navigationController?.pushViewController(searchVC, animated: true )
    }
    
    @IBAction func cameraBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default)
        { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                //let imagePicker = UIImagePickerController()
                self.imagePicker.sourceType =
                    UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        let gallery = UIAlertAction(title: "Photo Library", style: .default)
        { (action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.savedPhotosAlbum)
            {
                //let imagePicker = UIImagePickerController()
                self.imagePicker.sourceType =
                    UIImagePickerControllerSourceType.photoLibrary
                //imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        { (action:UIAlertAction) in
            
        }
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        //let image = resizeImage(image: img, toTheSize: CGSize(width: screenSize.width, height: screenSize.width))
        let size = CGSize(width: 152, height: 152)
        let image = img.af_imageAspectScaled(toFill: size)
        cameraBtn.setImage(image, for: .normal)
        photoFlag = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func typeBtnAction(_ button:UIButton)
    {
        if button.tag == 1001
        {
            type = "new"
            typeImgView.image = UIImage(named: "new_active")
        }
        else if button.tag == 1002
        {
            type = "used"
            typeImgView.image = UIImage(named: "used_active")
        }
        else
        {
            type = "both"
            typeImgView.image = UIImage(named: "both_active")
        }
    }
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnAction(_ button:UIButton)
    {
        let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController"))as! SearchViewController
        self.navigationController?.pushViewController(searchVC, animated: true )
    }
    
    @IBAction func addBookBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if !photoFlag
        {
            alert.message = "Please add book picture."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtName.text?.isEmpty)!
        {
            alert.message = "Please enter book name."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtLanguage.text?.isEmpty)!
        {
            alert.message = "Please enter book language."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtAuthor.text?.isEmpty)!
        {
            alert.message = "Please enter author name."
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            addBook()
        }
    }
    
    func addBook()
    {
        let language = txtLanguage.text!
        let name = txtName.text!
        let author = txtAuthor.text!
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/addBook")!)
            request.httpMethod = "POST"
            
            let photoStr = convertImageToBase64(image: (cameraBtn.imageView?.image)!)

            let postParameters = String(format:"u_id=%i&name=%@&language=%@&@&author=%@&type=%@&image=%@", userObj.userID, name, language, author, type, photoStr)
            
            request.httpBody = postParameters.data(using: .utf8)
//            //print(postParameters)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                DispatchQueue.main.async()
                    {
                        MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    alert.message = "The network connection was lost. Please try again."
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                
                let jsonResult = convertToDictionary(text: responseString!)
//                print(jsonResult)
                
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        DispatchQueue.main.async {
                            
                            let bookObj = BookObject()
                            bookObj.bookID = jsonResult!["b_id"] as! Int
                            bookObj.bookName = self.txtName.text! as NSString
                            bookObj.language = self.txtLanguage.text! as NSString
                            bookObj.author = self.txtAuthor.text! as NSString
                            bookObj.bookType = self.type as NSString
                            bookObj.photo = self.cameraBtn.imageView?.image
                            
                            userObj.addedBooksArray.add(bookObj)
                            
                            self.cameraBtn.setImage(UIImage(named: "add_pic"), for: .normal)
                            self.txtName.text = ""
                            self.txtAuthor.text = ""
                            self.txtLanguage.text = ""
                            self.type = "new"
                            self.typeImgView.image = UIImage(named: "new_active")
                            alert.message = "Book has been added successfully."
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else
                {
                    alert.message = "The network connection was lost. Please try again."
                    self.present(alert, animated: true, completion: nil)
                }
            }
            task.resume()
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            alert.message = "You are not connected to the internet. Please check your Wifi or Data network."
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        hideKeyboard()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeyboard()
    }
    
    func hideKeyboard()
    {
        txtLanguage.resignFirstResponder()
        txtName.resignFirstResponder()
        txtAuthor.resignFirstResponder()
    }
}

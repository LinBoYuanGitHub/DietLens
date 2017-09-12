//
//  FirstViewController.swift
//  DietLens
//
//  Created by singgee on 5/7/17.
//  Copyright © 2017 wellnessNext. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController,UIImagePickerControllerDelegate,

UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    let picker = UIImagePickerController()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imagePlacement: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        
        return cell
    }

    @IBAction func TakePhoto(_ sender: Any)
    {
        let im = UIImagePickerController()
        im.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            im.sourceType = UIImagePickerControllerSourceType.camera
        }
        else
        {
            im.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        im.allowsEditing = true
        im.mediaTypes = UIImagePickerController.availableMediaTypes(for: im.sourceType)!
        present(im, animated: true, completion: nil)
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)
    {
        imagePlacement.contentMode = .scaleAspectFit //3
        imagePlacement.image = image //4
        dismiss(animated: true) { 
            //let imageData = UIImageJPEGRepresentation(image, 0.6)
            //let compressedJPEGImage = UIImage(data: imageData!)
            self.uploadToImgRecognition(imgInData: UIImageJPEGRepresentation(image, 0.6)!)
            //UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
                        //print("hehe")
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToImgRecognition(imgInData:Data)
    {
        
        
        var r = URLRequest(url: URL(string: String("http://47.88.168.177:8888/process/"))!)
        r.httpMethod = "POST"
        //var r = URLRequest(url: URL(String("http://128.0.0.1")))
        let imgID = "0000000124"
        let mimeType = "image/jpg"
        let boundary = "----\(UUID().uuidString)"
        r.setValue("multipart/form-data; boundary=\(boundary)",forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"id\"\r\n\r\n")
        body.appendString("\(imgID)\r\n")
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"photo\"; filename=\"blob\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(imgInData)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        body.appendString("\r\n")
        
        r.httpBody = body as Data
        let task = URLSession.shared.dataTask(with: r, completionHandler:
        {
            data, response, error in
            guard let d = data, error == nil else
            {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {
                print("Status code is \(httpStatus.statusCode)")
                print("response is \(response)")
            }
            
            do
            {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
                {
                    var results = ""
                    if let responseResult = json as? Dictionary<String, AnyObject>
                    {
                        if let recognitionResult = responseResult["image_result"] as? Array<String>
                        {
                            for index in 0..<recognitionResult.count
                            {
                                print("\(index):\(recognitionResult[index])")
                                if(index == recognitionResult.count-1)
                                {
                                    results += recognitionResult[index]
                                }
                                else
                                {
                                    results += "\(recognitionResult[index]),"
                                }
                            }
                        }
                        if let imageID = responseResult["image_id"] as? String
                        {
                            print("imgID:\(imageID)")
                        }
                        if let imagePath = responseResult["image_path"] as? String
                        {
                            print("img path:\(imagePath)")
                        }
                    }
                    
                    let alertController = UIAlertController(title: "Recognition result!", message: results, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            catch let error
            {
                print (error.localizedDescription)
            }
        })
        task.resume()
        
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

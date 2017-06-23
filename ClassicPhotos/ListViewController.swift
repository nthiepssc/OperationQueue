//
//  ViewController.swift
//  ClassicPhotos
//
//  Created by Tuan Anh Ngo on 6/23/17.
//  Copyright © 2017 TuanAnh. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var photos = NSDictionary(contentsOf:dataSourceURL!)!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ListViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        let rowKey = photos.allKeys[indexPath.row] as! String
        
        var image : UIImage?
        if let imageURL = URL(string:photos[rowKey] as! String),
            let imageData = try? Data(contentsOf: imageURL){
            //1
            let unfilteredImage = UIImage(data:imageData)
            //2
            image = self.applySepiaFilter(unfilteredImage!)
        }
        
        // Configure the cell...
        cell.textLabel?.text = rowKey
        if image != nil {
            cell.imageView?.image = image!
        }
        
        return cell
    }
    
    func applySepiaFilter(_ image:UIImage) -> UIImage? {
        let inputImage = CIImage(data: UIImagePNGRepresentation(image)!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        if let outputImage = filter?.outputImage {
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
            return UIImage(cgImage: outImage!)
        }
        return nil
        
    }
}


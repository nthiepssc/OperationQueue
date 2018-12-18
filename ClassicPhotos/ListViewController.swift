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
    lazy var photos: [PhotoRecord] = []
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        tableView.dataSource = self
        tableView.delegate = self
        self.fetchPhotoDetails()
        
        // operation
        let blockOperation = BlockOperation {
            // call method
            print("do something")
        }
        
        // block object
        let block = {
            print("block")
        }
        blockOperation.addExecutionBlock(block)
        
        blockOperation.start()
    }
    
    private func registerCell() {
        self.tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
    }
    
    func fetchPhotoDetails() {
        /* small data
        let record1 = PhotoRecord(name: "Record 1", url: URL(string: "http://sohanews.sohacdn.com/thumb_w/660/2018/6/20/photo1529462190578-1529462190578408130933.jpg")!)
        let record2 = PhotoRecord(name: "Record 2", url: URL(string: "https://nld.mediacdn.vn/thumb_w/660/2018/12/12/2-1544597270040168044932.jpg")!)
        let record3 = PhotoRecord(name: "Record 3", url: URL(string: "http://sohanews.sohacdn.com/thumb_w/660/2017/photo1512931613478-1512931613481.jpg")!)
        let record4 = PhotoRecord(name: "Record 4", url: URL(string: "https://avatar-nct.nixcdn.com/playlist/2017/01/17/7/8/c/7/1484620963031_500.jpg")!)
        let record5 = PhotoRecord(name: "Record 5", url: URL(string: "https://i.imgur.com/YGT4Rkv.jpg")!)
        let record6 = PhotoRecord(name: "Record 6", url: URL(string: "https://i.ytimg.com/vi/a_p1pPGbKos/maxresdefault.jpg")!)
        let record7 = PhotoRecord(name: "Record 7", url: URL(string: "http://www.elle.vn/wp-content/uploads/2016/12/29/ca-si-my-tam-09.jpg")!)
        let record8 = PhotoRecord(name: "Record 8", url: URL(string: "http://2sao.vietnamnetjsc.vn/images/2017/12/21/08/41/MY-TAMTAM-9-10.jpg")!)
        let record9 = PhotoRecord(name: "Record 9", url: URL(string: "https://image.thanhnien.vn/665/uploaded/caotung/2017_12_01/mt3_uxwg.jpg")!)
        let record10 = PhotoRecord(name: "Record 10", url: URL(string: "http://laodongthudo.vn/stores/news_dataimages/thanhtrung/082018/29/09/my-tam-duoc-moi-xuat-hien-giua-loat-sao-han-va-8000-khan-gia-xu-kim-chi-27-.2303.jpg")!)
        let record11 = PhotoRecord(name: "Record 11", url: URL(string: "https://nld.mediacdn.vn/thumb_w/540/2018/11/14/my-tam-son-tung-mtp-se-gop-mat-trong-le-hoi-am-thuc-lon-nhat-tai-sai-gon-1-1512353907-995-width1378height2067-15422619499151729071207.jpg")!)
        let record12 = PhotoRecord(name: "Record 12", url: URL(string: "https://kenh14cdn.com/2018/11/9/anh-chup-man-hinh-2018-11-09-luc-215302-15417751941991966149512.png")!)
        let record13 = PhotoRecord(name: "Record 13", url: URL(string: "https://www.elle.vn/wp-content/uploads/2018/07/02/MyTam-05-1024x1024.jpg")!)
        let record14 = PhotoRecord(name: "Record 14", url: URL(string: "https://photo-resize-zmp3.zadn.vn/w240h240_jpeg/avatars/a/3/a3b8a090fa8e0b4e4ac7d4f028022a87_1460105189.jpg")!)
        let record15 = PhotoRecord(name: "Record 15", url: URL(string: "http://giadinh.mediacdn.vn/2018/6/23/photo-0-1529721029137102944547.jpg")!)
        self.photos = [record1, record2, record3, record4, record5, record6, record7, record8, record9, record10, record11, record12, record13, record14, record15]
        */
        
        // Big data
        let record1 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/uploads/2015/02/Airbus_Pleiades_50cm_8bit_RGB_Yogyakarta.jpg")!)
        let record2 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/uploads/2015/02/DigitalGlobe_WorldView2_50cm_8bit_Pansharpened_RGB_DRA_Rome_Italy_2009DEC10_8bits_sub_r_1.jpg")!)
        let record3 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/uploads/2015/02/DigitalGlobe_WorldView1_50cm_8bit_BW_DRA_Bangkok_Thailand_2009JAN06_8bits_sub_r_1.jpg")!)
        let record4 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/themes/effigis_2014/img/GeoEye_GeoEye1_50cm_8bit_RGB_DRA_Mining_2009FEB14_8bits_sub_r_15.jpg")!)
        let record5 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/uploads/2015/02/DigitalGlobe_QuickBird_60cm_8bit_RGB_DRA_Boulder_2005JUL04_8bits_sub_r_1.jpg")!)
        let record6 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/uploads/2015/02/Infoterra_Terrasar-X_1_75_m_Radar_2007DEC15_Toronto_EEC-RE_8bits_sub_r_12.jpg")!)
        let record7 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/uploads/2015/02/GeoEye_Ikonos_1m_8bit_RGB_DRA_Oil_2005NOV25_8bits_r_1.jpg")!)
        let record8 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/themes/effigis_2014/img/RapidEye_RapidEye_5m_RGB_Altotting_Germany_Agriculture_and_Forestry_2009MAY17_8bits_sub_r_2.jpg")!)
        let record9 = PhotoRecord(name: "Record 15", url: URL(string: "http://www.effigis.com/wp-content/uploads/2015/02/Iunctus_SPOT5_5m_8bit_RGB_DRA_torngat_mountains_national_park_8bits_1.jpg")!)
        let record10 = PhotoRecord(name: "Record 15", url: URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/74000/74393/world.topo.200407.3x21600x21600.D1.png")!)
        let record11 = PhotoRecord(name: "Record 15", url: URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/74000/74393/world.topo.200407.3x21600x21600.D2.png")!)
        let record12 = PhotoRecord(name: "Record 15", url: URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/74000/74393/world.topo.200407.3x21600x21600.C2.png")!)
        let record13 = PhotoRecord(name: "Record 15", url: URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/74000/74393/world.topo.200407.3x21600x21600.C1.png")!)
        let record14 = PhotoRecord(name: "Record 15", url: URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/74000/74393/world.topo.200407.3x21600x21600.B2.png")!)
        let record15 = PhotoRecord(name: "Record 15", url: URL(string: "https://eoimages.gsfc.nasa.gov/images/imagerecords/74000/74393/world.topo.200407.3x21600x21600.B1.png")!)
        self.photos = [record1, record2, record3, record4, record5, record6, record7, record8, record9, record10, record11, record12, record13, record14, record15]
        self.tableView.reloadData()
    }


}

extension ListViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as? ImageCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        let photoDetails = photos[indexPath.row]
        cell.nameLabel.text = photoDetails.name
        cell.myImageView.image = photoDetails.image
        cell.progressLabel.text = String(format: "%0.0f", photoDetails.progress) + "%"
        if photoDetails.state == .Downloaded {
            self.startOperationsForPhotoRecord(photoDetails: photoDetails, indexPath: indexPath)
        }
        cell.startDownLoadButton.setTitle(self.getTitleForButton(photoDetails), for: .normal)
        return cell
    }
    
    private func getTitleForButton(_ photoRecord: PhotoRecord) -> String {
        switch photoRecord.state {
        case .New, .Failed, .Downloaded, .Pause:
            return "Start"
        case .Filtered:
            return "Finished"
        case .IsDownloading, .InQueue:
            return "Pause"
        }
    }
    
    func startOperationsForPhotoRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        switch (photoDetails.state) {
        case .New, .Failed:
            startDownloadForRecord(photoDetails: photoDetails, indexPath: indexPath)
            break;
        case .Downloaded:
            startFiltrationForRecord(photoDetails: photoDetails, indexPath: indexPath)
            break;
        default:
            break;
        }
    }
    
    func startDownloadForRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        if pendingOperations.downloadsInProgress[indexPath] != nil {
            return
        }
        photoDetails.state = .InQueue
        let downloader = ImageDownloader(photoRecord: photoDetails)
        downloader.progress = {
            if !self.tableView.isDragging && !self.tableView.isDecelerating {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
            }
        }
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.pendingOperations.removeDownloadInProgress(indexPath)
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
            })
        }
        self.pendingOperations.addDownloadQueue(downloader, at: indexPath)
    }
    
    func startFiltrationForRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        if pendingOperations.filtrationsInProgress[indexPath] != nil{
            return
        }
        let filterer = ImageFiltration(photoRecord: photoDetails)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.pendingOperations.removeFilterInProgress(indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            })
        }
        self.pendingOperations.addFilterationQueue(filterer, at: indexPath)
    }
}

extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: ImageCellDelegate {
    
    func startDownloadAt(_ cell: ImageCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let phototRecord = self.photos[indexPath.row]
        if let operation = self.pendingOperations.downloadsInProgress[indexPath] {
            // If queue is excuting
            switch phototRecord.state {
            case .New:
                // do something
                break
            case .InQueue:
                var operations = self.pendingOperations.downloadQueue.operations
                if let index = operations.lastIndex(of: operation) {
                    operation.cancel()
                    operations.remove(at: index)
                    self.pendingOperations.removeDownloadInProgress(indexPath)
                }
                phototRecord.state = .New
                break
            case .IsDownloading:
                operation.pause()
                phototRecord.state = .Pause
                self.pendingOperations.pauseQueue()
                break
            case .Pause:
                operation.resume()
                phototRecord.state = .IsDownloading
                break
            case .Downloaded:
                self.startOperationsForPhotoRecord(photoDetails: phototRecord, indexPath: indexPath)
                break
            case .Filtered:
                // do something
                break
            case .Failed:
                self.startOperationsForPhotoRecord(photoDetails: phototRecord, indexPath: indexPath)
                break
            }
        } else {
            self.startOperationsForPhotoRecord(photoDetails: phototRecord, indexPath: indexPath)
        }
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .none)
        self.tableView.endUpdates()
    }
}

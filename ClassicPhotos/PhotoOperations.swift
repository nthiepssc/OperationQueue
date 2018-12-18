//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by van.tien.tu on 12/18/18.
//  Copyright © 2018 TuanAnh. All rights reserved.
//

import UIKit

enum PhotoRecordState {
    case New, InQueue, IsDownloading, Pause, Downloaded, Filtered, Failed
}

class PhotoRecord: NSObject {
    let name: String
    let url: URL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder.png")
    var progress: Float = 0
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

// Operation Manager
class PendingOperations {
    
    fileprivate var maxConcurrentOperationCount: Int = 2
    
    lazy var downloadsInProgress: [IndexPath: ImageDownloader] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = self.maxConcurrentOperationCount
        return queue
    }()
    
    lazy var filtrationsInProgress: [IndexPath: ImageFiltration] = [:]
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = self.maxConcurrentOperationCount
        return queue
    }()
    
    // download queue
    func addDownloadQueue(_ queue: ImageDownloader, at indexPath: IndexPath) {
        let operations = Set(Array(self.downloadsInProgress.values))
        let queuePausings = operations.filter { (operation) -> Bool in
            return operation.photoRecord.state == .Pause
        }
        
        if queuePausings.count > 0 {
            self.maxConcurrentOperationCount = queuePausings.count + 2
            self.downloadQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount
        }
        self.downloadsInProgress[indexPath] = queue
        self.downloadQueue.addOperation(queue)
    }
    
    func removeDownloadInProgress(_ indexPath: IndexPath) {
        let operations = Set(Array(self.downloadsInProgress.values))
        let queuePausings = operations.filter { (operation) -> Bool in
            return operation.photoRecord.state == .Pause
        }
        self.downloadsInProgress.removeValue(forKey: indexPath)
        if self.maxConcurrentOperationCount > queuePausings.count + 2 {
            self.maxConcurrentOperationCount -= 1
            self.downloadQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount
        }
    }
    
    //filteration queue
    func addFilterationQueue(_ queue: ImageFiltration, at indexPath: IndexPath) {
        self.filtrationsInProgress[indexPath] = queue
        self.filtrationQueue.addOperation(queue)
        self.filtrationQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount
    }
    
    func removeFilterInProgress(_ indexPath: IndexPath) {
        self.filtrationsInProgress.removeValue(forKey: indexPath)
        self.filtrationQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount
    }
    
    // actions
    func pauseQueue() {
        let operations = Set(Array(self.downloadsInProgress.values))
        let queuePausings = operations.filter { (operation) -> Bool in
            return operation.photoRecord.state == .Pause
        }
        if queuePausings.count > 0 {
            self.maxConcurrentOperationCount = queuePausings.count + 2
            self.downloadQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount
        }
    }
}

protocol Downloadable {
    func resume()
    func pause()
}

extension ImageDownloader: Downloadable {
    
    func resume() {
        if let data = self.data {
            self.task = self.session.downloadTask(withResumeData: data)
            self.task.resume()
        } else {
            self.task = session.downloadTask(with: self.photoRecord.url)
        }
    }
    
    func pause() {
        if let task = self.task {
            task.cancel { [weak self] (data) in
                guard let self = self else { return }
                self.data  = data
            }
        }
    }
}

class ImageDownloader: Operation {
    //1
    let photoRecord: PhotoRecord
    //2
    fileprivate var semaphore: DispatchSemaphore!
    var progress: (() -> ())?
    
    fileprivate var session: URLSession!
    fileprivate var task: URLSessionDownloadTask!
    fileprivate var data: Data?
    fileprivate var previousOffset: Float = 0
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        self.photoRecord.state = .IsDownloading
        semaphore = DispatchSemaphore(value: 0)
        /* small data
        URLSession.shared.dataTask(with: self.photoRecord.url) { [weak self] (data, response, error) in
            guard let strongSelf = self else {
                semaphore.signal()
                return
            }
            if strongSelf.isCancelled {
                semaphore.signal()
                return
            }
            if let dataImage = data {
                strongSelf.photoRecord.image = UIImage(data: dataImage)
                strongSelf.photoRecord.state = .Downloaded
            } else {
                strongSelf.photoRecord.state = .Failed
            }
            semaphore.signal()
        }.resume()
        semaphore.wait()
        */
        // Big data
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        self.task = session.downloadTask(with: self.photoRecord.url)
        self.task.resume()
        semaphore.wait()
        /*
        //5
        let imageData = try? Data(contentsOf: self.photoRecord.url)
        //6
        if self.isCancelled {
            return
        }
        //7
        if let image = imageData {
            self.photoRecord.image = UIImage(data:image)
            self.photoRecord.state = .Downloaded
        } else {
            self.photoRecord.state = .Failed
            print("download imgae was failed")
        }
         */
    }
}

extension ImageDownloader: URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    // URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if self.isCancelled {
            return
        }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100
        self.photoRecord.progress = progress
        let distance = Int(progress) - Int(self.previousOffset)
        if distance >= 1 {
            self.progress?()
            self.previousOffset = progress
        }
        print(self.photoRecord.progress)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        if self.isCancelled {
            return
        }
        self.photoRecord.progress = Float(fileOffset) / Float(expectedTotalBytes) * 100
        self.progress?()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print(location)
        if self.isCancelled {
            return
        }
        self.photoRecord.progress = 100
        self.photoRecord.image = self.downsample(imageURL: location, to: UIScreen.main.bounds.size, scale: 1)
        self.photoRecord.state = .Downloaded
        semaphore.signal()
        print("did finished download")
    }
    
    // URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if self.isCancelled {
            return
        }
        self.photoRecord.state = .Pause
        if let error = error as NSError? {
            let data = error.userInfo[NSURLSessionDownloadTaskResumeData]! as? Data
            self.data = data
        }
        self.progress?()
        print("something wrong")
    }
    
    fileprivate func downsample(imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        let maxDimensionInPiexels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                 kCGImageSourceShouldCacheImmediately: true,
                                 kCGImageSourceCreateThumbnailWithTransform: true,
                                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPiexels] as CFDictionary
        let downsampleImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampleImage)
    }
}

class ImageFiltration: Operation {
    
    let photoRecord: PhotoRecord
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        if self.photoRecord.state != .Downloaded {
            return
        }
        if let filteredImage = self.applySepiaFilter(self.photoRecord.image!) {
            self.photoRecord.image = filteredImage
            self.photoRecord.state = .Filtered
        } else {
            print("No filtered")
        }
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

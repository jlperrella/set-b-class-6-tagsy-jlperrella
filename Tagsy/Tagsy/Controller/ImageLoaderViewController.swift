//
//  ImageLoaderViewController.swift
//  Tagsy
//
//  Created by jp on 2019-04-01.
//  Copyright © 2019 Jordan Perrella. All rights reserved.
//

import UIKit

class ImageLoaderViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var progressView: UIProgressView!
  
  var delegate: ImageLoaderViewControllerDelegate?
  var uploadedImage: UploadedImage?
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // set the image view image
    if let uploaded = uploadedImage {
      imageView.image = uploaded.image
    }
    
    // make sure the progress view is always in front of the image view
    view.sendSubviewToBack(imageView)
    
    uploadImage()
  }
  
  private func uploadImage() {
    guard let image = uploadedImage else { return }
    
    // make post request to Imagga API to upload our imagee
    ImaggaAPI.shared.postUpload(image: image.image, progressCompletion: { progress in
      // update our progress view as progress data is received
      self.progressView.progress = progress
    }) { (tags, colors, id) in
      // save our tag and color data in our UploadedImage object
      if let tags = tags {
        self.uploadedImage?.tags = tags
      }
      
      if let colors = colors {
        self.uploadedImage?.colors = colors
      }
      
      if let id = id {
        self.uploadedImage?.id = id
      }
      
      if let uploaded = self.uploadedImage {
        // if we have a delegate
        // call the addUploadedImage method with our UploadedImage object
        self.delegate?.addUploadedImage(uploadedImage: uploaded)
      }
      
      // if we have a delegate
      // tell them they can dismiss us
      self.delegate?.dismiss()
    }
  }
}

//
//  ImageDetailViewController.swift
//  Tagsy
//
//  Created by jp on 2019-04-01.
//  Copyright © 2019 Jordan Perrella. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var colorsCollectionView: UICollectionView!
  @IBOutlet weak var tagsCollectionView: UICollectionView!
  
  var uploadedImage: UploadedImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    colorsCollectionView.delegate = self
    tagsCollectionView.delegate = self
    
    colorsCollectionView.dataSource = self
    tagsCollectionView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    loadDataIntoUI()
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == tagsCollectionView {
      return uploadedImage?.tags.count ?? 0
    }
    
    if collectionView == colorsCollectionView {
      return uploadedImage?.colors.count ?? 0
    }
    
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch collectionView {
    case tagsCollectionView:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagCell
      
      cell?.textLabel.text = uploadedImage?.tags[indexPath.row]
      
      return cell!
    case colorsCollectionView:
      let cell = colorsCollectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
      
      if let color: ImageColor = uploadedImage?.colors[indexPath.row] {
        cell.contentView.backgroundColor = UIColor(red: CGFloat(color.red) / 255.0, green: CGFloat(color.green) / 255.0, blue: CGFloat(color.blue) / 255.0, alpha: 1.0)
      }
      
      return cell
    default:
      let cell = colorsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      return cell
    }
  }
  
  func loadDataIntoUI() {
    guard let uploaded = uploadedImage else { return }
    
    imageView.image = uploaded.image
    
    tagsCollectionView.reloadData()
    colorsCollectionView.reloadData()
  }
    



}

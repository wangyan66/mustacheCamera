//
//  MediaCell.swift
//  AVFoundation-MediaFeed
//
//  Created by 王焱 on 2023/1/24.
//


import UIKit

class MediaCell: UICollectionViewCell {
  
  @IBOutlet weak var mediaImageView: UIImageView!
  
  public func configureCell(for mediaObject: CDMediaObject) {
    if let imageData = mediaObject.imageData {
      // converts a Data object to a UIImage
      mediaImageView.image = UIImage(data: imageData)
    }
        
    // create a video preview thumbnail
    if let videoURL = mediaObject.videoData?.convertToURL() {
      let image = videoURL.videoPreviewThumnail() ?? UIImage(systemName: "heart")
      mediaImageView.image = image
    }
  }
}

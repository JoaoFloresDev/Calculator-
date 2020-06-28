//
//  VideoPlayerViewController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 27/06/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoPlayerViewController: UIViewController {

  
  @IBAction func playVideo(_ sender: AnyObject) {
    VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
  }
}

// MARK: - UIImagePickerControllerDelegate

extension VideoPlayerViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    guard let mediaType = info[UIImagePickerControllerMediaType] as? String,
      mediaType == (kUTTypeMovie as String),
      let url = info[UIImagePickerControllerMediaURL] as? URL
      else { return }
    
    dismiss(animated: true) {
      let player = AVPlayer(url: url)
      let vcPlayer = AVPlayerViewController()
      vcPlayer.player = player
      self.present(vcPlayer, animated: true, completion: nil)
    }
  }
}

// MARK: - UINavigationControllerDelegate

extension VideoPlayerViewController: UINavigationControllerDelegate {
}


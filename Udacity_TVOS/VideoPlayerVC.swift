//
//  VideoPlayerVC.swift
//  Udacity_TVOS
//
//  Created by inailuy on 7/13/16.
//
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class VideoPlayerVC: AVPlayerViewController {
    var item :Item!
    var index :Int!
    var avPlayer :AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        createTapGestures()
        
        playWithVideoId((item.snippet.resourceId?.videoId)!)
        
        NotificationCenter.default.addObserver(self, selector:#selector(VideoPlayerVC.audioStateChanged), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func createTapGestures() {
        let tapMenuGestureRec = UITapGestureRecognizer(target: self, action: #selector(VideoPlayerVC.menuButtonPressed(_:)))
        tapMenuGestureRec.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
        view.addGestureRecognizer(tapMenuGestureRec)
        
        let tapPlayGestureRec = UITapGestureRecognizer(target: self, action: #selector(VideoPlayerVC.playButtonPressed(_:)))
        tapPlayGestureRec.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue as Int)]
        view.addGestureRecognizer(tapPlayGestureRec)
    }
    
    func menuButtonPressed(_ gesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    func playButtonPressed(_ gesture: UITapGestureRecognizer) {
        avPlayer.rate == 0 ? avPlayer.play() : avPlayer.pause()
    }
    
    func audioStateChanged() {
        let playlistItemArray = YoutubeAPI.sharedInstance.playlistItems.items
        if index != playlistItemArray.count {
            index = index + 1
            item = playlistItemArray[index]
            playWithVideoId(item.snippet.resourceId!.videoId)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func playWithVideoId(_ videoId :String) {
        SVProgressHUD.show()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let youTubeString : String = "https://www.youtube.com/watch?v=" + (self.item.snippet.resourceId?.videoId)!
            let videos : NSDictionary = HCYoutubeParser.h264videos(withYoutubeURL: (URL(string: youTubeString)))! as NSDictionary
            let urlString : String = videos["medium"] as! String//hd720
            let asset = AVAsset(url: URL(string: urlString)!)
            DispatchQueue.main.async(execute: {
                let avPlayerItem = AVPlayerItem(asset:asset)
                self.avPlayer = AVPlayer(playerItem: avPlayerItem)
                let avPlayerLayer  = AVPlayerLayer(player: self.avPlayer)
                avPlayerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
                self.view.layer.addSublayer(avPlayerLayer)
                
                let playerViewController = AVPlayerViewController()
                playerViewController.player = self.avPlayer
                
                self.addChildViewController(playerViewController)
                self.view.addSubview(playerViewController.view)
                playerViewController.didMove(toParentViewController: self)
                
                self.avPlayer.play()
                SVProgressHUD.dismiss()
            })
        }
    }
}

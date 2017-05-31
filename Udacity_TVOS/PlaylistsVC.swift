//
//  PlaylistsVC.swift
//  Udacity_TVOS
//
//  Created by inailuy on 7/8/16.
//
//

import UIKit

class PlaylistsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let defaultFrameImg = CGRect(x: 40, y: 15, width: 550, height: 300)
    let focusFrameImg = CGRect(x: 0, y: 0, width: 640, height: 360)
    let defaultFrameLabel = CGRect(x: 40, y: 315, width: 550, height: 30)
    let focusFrameLabel = CGRect(x: 0, y: 315, width: 640, height: 30)
    
    var selectedIndexPath :IndexPath?
    
    enum Tag :Int {
        case imageView = 100
        case label = 101
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Presunto Vegetariano"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playlistFinishedLoading),
            name: NSNotification.Name(rawValue: YoutubePostNotification),
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func playlistFinishedLoading(_ notification: Notification){
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "PresentPlayerItems" {
            let vc = segue.destination as! PlaylistItemsVC
            vc.selectedItem = YoutubeAPI.sharedInstance.playlist.items[(selectedIndexPath?.row)!] as Item
        }
    }
    //MARK: CollectionView DataSource/Delegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = YoutubeAPI.sharedInstance.playlist.items[indexPath.row] as Item
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath)
        let imgView = cell.viewWithTag(Tag.imageView.rawValue) as! UIImageView
        let label = cell.viewWithTag(Tag.label.rawValue) as! UILabel
        
        label.text = item.snippet.title
        YoutubeAPI.sharedInstance.loadImages(item.snippet.thumbnails.medium.url) {
            (result: UIImage) in
                imgView.image = result
        }
        
        if cell.gestureRecognizers?.count == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(PlaylistsVC.collectionCellTapped(_:)))
            tap.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue as Int)]
            cell.addGestureRecognizer(tap)
        }
        
        return cell
    }
    
    func collectionCellTapped(_ gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? UICollectionViewCell {
            selectedIndexPath = collectionView.indexPath(for: cell)
            performSegue(withIdentifier: "PresentPlayerItems", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if YoutubeAPI.sharedInstance.playlist != nil {
            count = YoutubeAPI.sharedInstance.playlist.items.count
        }
        return count
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let prev = context.previouslyFocusedView {
            let imgView = prev.viewWithTag(Tag.imageView.rawValue) as? UIImageView
            let label = prev.viewWithTag(Tag.label.rawValue) as? UILabel
            UIView.animate(withDuration: 0.1, animations: {() -> Void in
                imgView?.frame = self.defaultFrameImg//TODO:crashing bug
                label?.frame = self.defaultFrameLabel
            })
        }
        
        if let next = context.nextFocusedView {
            let imgView = next.viewWithTag(Tag.imageView.rawValue) as? UIImageView
            let label = next.viewWithTag(Tag.label.rawValue) as? UILabel
            UIView.animate(withDuration: 0.1, animations: {() -> Void in
                imgView?.frame = self.focusFrameImg
                label?.frame = self.focusFrameLabel
            })
        }
    }
    //MARK: UIScrollViewDelegate 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //getting the scroll offset
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height && YoutubeAPI.sharedInstance.playlist != nil {
            //at the bottom of the view
            YoutubeAPI.sharedInstance.getNextPlaylistModel()
        }
    }
}

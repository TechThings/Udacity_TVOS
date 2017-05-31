//
//  PlaylistItemsVC.swift
//  Udacity_TVOS
//
//  Created by inailuy on 7/13/16.
//
//

import Foundation
import UIKit

class PlaylistItemsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    var selectedItem :Item?
    var selectedIndexPath :IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedItem?.snippet.title
        YoutubeAPI.sharedInstance.getPlaylistItems((selectedItem?.id)!)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "videoSegue" {
            let vc = segue.destination as! VideoPlayerVC
            let item = YoutubeAPI.sharedInstance.playlistItems.items[selectedIndexPath!.row] as Item
            vc.item = item
            vc.index = selectedIndexPath!.row
        }
    }
    
    func tableCellTapped(_ gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? UITableViewCell {
            selectedIndexPath = tableView.indexPath(for: cell)
            performSegue(withIdentifier: "videoSegue", sender: nil)
        }
    }
    
    @objc func playlistFinishedLoading(_ notification: Notification){
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    //MARK: TableView DataSource/Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if YoutubeAPI.sharedInstance.playlistItems != nil {
            count = YoutubeAPI.sharedInstance.playlistItems.items.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = YoutubeAPI.sharedInstance.playlistItems.items[indexPath.row] as Item
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistItemId")
        cell?.textLabel?.text = item.snippet.title
        
        if cell!.gestureRecognizers?.count == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(PlaylistItemsVC.tableCellTapped(_:)))
            tap.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue as Int)]
            cell!.addGestureRecognizer(tap)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let index = context.nextFocusedIndexPath
        if index != nil {
            let item = YoutubeAPI.sharedInstance.playlistItems.items[index!.row] as Item
            YoutubeAPI.sharedInstance.loadImages(item.snippet.thumbnails.high.url, completion: {
                (result: UIImage) in
                self.imageView.image = result
            })
        }
    }
}

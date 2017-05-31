//
//  YoutubeAPI.swift
//  Udacity_TVOS
//
//  Created by inailuy on 7/8/16.
//
//

import Foundation
import UIKit

let baseURL = "https://www.googleapis.com/youtube/v3/"
let playlistItemsSuffix = "playlistItems?"
let playlistSuffix = "playlists?"
let suffixParameters = "part=snippet&maxResults=50"
let channelId = "&channelId=UCLsif3JUgJ_wA5d4I-mrAVQ"//UCX59TymRoApxFu0t0tyQmFA"//UCtdrvQPKPB7dQG5XJsbillQ"//UCBVCi5JbYmfG3q5MEuoWdOw"
let APIkey = "&key=AIzaSyBV2lTiVQqrpoxkUdgCtQ7utwRVwjgNFTg"

let YoutubePostNotification = "fetchedAllPlaylists"

class YoutubeAPI {
    static let sharedInstance = YoutubeAPI()
    var playlist: Playlist!
    var playlistItems: Playlist!
    var imageDictionary = NSMutableDictionary()
    
    func getPlaylistModel() {
        let string = baseURL + playlistSuffix + suffixParameters + channelId + APIkey
        let url = URL(string: string)
        SVProgressHUD.show()
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            if error == nil {
                do {
                    let jsonResults = try JSONSerialization.jsonObject(with: data!, options: [])
                    self.playlist = Playlist(dictionary: jsonResults as! NSDictionary)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: YoutubePostNotification), object: nil)
                    SVProgressHUD.dismiss()
                    //print(jsonResults)
                } catch {
                    // failure
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
            }
        })
        task.resume()
    }
    
    func getNextPlaylistModel() {
        
        var pageToken = "&pageToken="
        if let token = playlist.nextPageToken {
            pageToken = pageToken + token
        } else {
            print("Carregar proximos")
        }
        let string = baseURL + playlistSuffix + suffixParameters + channelId + pageToken + APIkey
        let url = URL(string: string)
        SVProgressHUD.show()
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            if error == nil {
                do {
                    let jsonResults = try JSONSerialization.jsonObject(with: data!, options: [])
                    // creating new array to later insert new items
                    var array = self.playlist.items
                    self.playlist = Playlist(dictionary: jsonResults as! NSDictionary)
                    array.append(contentsOf: self.playlist.items)
                    self.playlist.items = array
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: YoutubePostNotification), object: nil)
                    SVProgressHUD.dismiss()
                } catch {
                    // failure
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
            }
        })
        task.resume()
    }
    
    func getPlaylistItems(_ playlistId: String) {
        let urlString = baseURL + playlistItemsSuffix + suffixParameters + "&playlistId=" + playlistId + APIkey
        let url = URL(string: urlString)
        SVProgressHUD.show()
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            if error == nil {
                do {
                    let jsonResults = try JSONSerialization.jsonObject(with: data!, options: [])
                    self.playlistItems = Playlist(dictionary: jsonResults as! NSDictionary)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: YoutubePostNotification), object: nil)
                    SVProgressHUD.dismiss()
                    //print(jsonResults)
                } catch {
                    // failure
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
            }
        })
        task.resume()
    }
    
    func loadImages(_ inputURL: String, completion: @escaping (_ result: UIImage) -> Void) {
        if let img = imageDictionary[inputURL] { // check if image already exists
            completion(img as! UIImage)
        } else {
            let imgUrl = URL(string: inputURL)
            let task = URLSession.shared.dataTask(with: imgUrl!, completionHandler: {(data, reponse, error) in
                if error == nil {
                    let img = UIImage(data: data!)
                    self.imageDictionary.setValue(img, forKey: inputURL)
                    DispatchQueue.main.async(execute: {
                        completion(img!)
                    })
                }
            })
            task.resume()
        }
    }
}

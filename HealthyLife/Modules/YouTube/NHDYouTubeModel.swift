//
//  NHDYouTubeModel.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 30/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import Foundation

class NHDYouTubeModel {
    
    var title = ""
    var thumbnail = ""
    var videoID = ""
    var videoURL: String {
        get {
            return Configuration.YouTubePath + videoID
        }
    }
    
    class func initWithArray(resultsDict: Dictionary<NSObject, AnyObject>) -> Array<NHDYouTubeModel> {
        
        var videosArray: Array<NHDYouTubeModel> = []

        let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
        
        // Loop through all search results and keep just the necessary data.
        for i in 0 ..< items.count {
            let snippetDict = items[i]["snippet"] as! Dictionary<NSObject, AnyObject>
            
            // Create a new dictionary to store the video details.
            let video = NHDYouTubeModel()
            video.title = snippetDict["title"] as! String
            video.thumbnail = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"] as! String
            video.videoID = (items[i]["id"] as! Dictionary<NSObject, AnyObject>)["videoId"] as! String
            
            // Append the desiredPlaylistItemDataDict dictionary to the videos array.
            videosArray.append(video)
        }

        return videosArray
    }
}
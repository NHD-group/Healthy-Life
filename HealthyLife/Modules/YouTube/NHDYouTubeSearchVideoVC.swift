//
//  NHDYouTubeSearchVideoVC.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 30/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

protocol NHDYouTubeSearchVideoVCDelegate: class {
    func onChooseVideo(video: NHDYouTubeModel)
}

class NHDYouTubeSearchVideoVC: BaseTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    weak var delegate: NHDYouTubeSearchVideoVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.becomeFirstResponder()

        tableView.estimatedRowHeight = 120
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(NHDYouTubeTableViewCell), forIndexPath: indexPath) as! NHDYouTubeTableViewCell
        
        let video = dataArray[indexPath.row] as! NHDYouTubeModel
        cell.initWithData(video)
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let video = dataArray[indexPath.row] as! NHDYouTubeModel
        NHDVideoPlayerViewController.showPlayer(nil, orLink: video.videoURL, title: video.title, inViewController: self)
    }
}

extension NHDYouTubeSearchVideoVC : UISearchBarDelegate {

    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        filterContentForSearchText(searchBar.text)
        dismissKeyboard()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        filterContentForSearchText(searchBar.text)
        dismissKeyboard()
    }
    
    
    func filterContentForSearchText(searchText: String?) {

        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(searchText ?? " ")&type=video&key=\(Configuration.GoogleApiKey)"
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let targetURL = NSURL(string: urlString)
        showLoading()
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary object.
                do {
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    self.dataArray = NHDYouTubeModel.initWithArray(resultsDict)
                    
                } catch {
                }
            }
            else {
                Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
            }
            
            self.hideLoading()
        })
    }
    
    // MARK: Custom method implementation
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
    }

}

extension NHDYouTubeSearchVideoVC: NHDYouTubeTableViewCellDelegate {
 
    func onChooseVideo(video: NHDYouTubeModel) {
        navigationController?.popViewControllerAnimated(true)
        delegate?.onChooseVideo(video)
    }
}
//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Adam Crabtree on 2/22/15.
//  Copyright (c) 2015 Adam Crabtree. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var statusTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = User.currentUser?.name
        let screename = User.currentUser?.screenname!
        self.screennameLabel.text = "@\(screename)"
        if let imageUrlString = User.currentUser?.profileImageUrl, let imageUrl = NSURL(string: imageUrlString) {
            self.thumbImageView.setImageWithURL(imageUrl)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onTweet(sender: AnyObject) {
        let status = self.statusTextView.text
        TwitterClient.sharedInstance.tweetWithCompletion(["status": status]) {
            (error) -> () in
            self.navigationController?.popViewControllerAnimated(true)
            if let vc = self.presentingViewController as? MainViewController {
                println("loading data")
                vc.loadData()
            }
        }
    }
}

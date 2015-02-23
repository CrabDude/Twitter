//
//  TweetViewController.swift
//  Twitter
//
//  Created by Adam Crabtree on 2/22/15.
//  Copyright (c) 2015 Adam Crabtree. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        nameLabel.text = tweet?.user?.name
        screennameLabel.text = tweet?.user?.screenname
        contentLabel.text = tweet?.text
        if let imageUrlString = tweet?.user?.profileImageUrl, let imageUrl = NSURL(string: imageUrlString) {
            thumbImageView.setImageWithURL(imageUrl)
        }
        
        if let createdAt = tweet?.createdAt {
            var formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .ShortStyle
            formatter.timeZone = NSTimeZone(abbreviation: "PST")
            timeLabel.text = formatter.stringFromDate(createdAt)
        }
        
        if tweet?.retweeted == true {
            retweetButton.setImage(UIImage(named:"1040-checkmark-toolbar-selected"), forState: .Normal)
            
        }
        
        
        if tweet?.favorited == true {
            favoriteButton.setImage(UIImage(named:"726-star-toolbar-selected"), forState: .Normal)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dc = segue.destinationViewController as? ComposeViewController {
            dc.tweet = tweet!
        }
    }
    
    
    @IBAction func onReply(sender: AnyObject) {
        self.performSegueWithIdentifier("detailsToComposeSegue", sender:tweet)
    }

    @IBAction func onRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweetWithCompletion(tweet!.id!) {
            (error) -> () in
            self.retweetButton.setImage(UIImage(named:"1040-checkmark-toolbar-selected"), forState: .Normal)
        }
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        TwitterClient.sharedInstance.favoriteWithCompletion(tweet!.id!) {
            (error) -> () in
            self.favoriteButton.setImage(UIImage(named:"726-star-toolbar-selected"), forState: .Normal)
        }
    }
}

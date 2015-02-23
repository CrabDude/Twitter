//
//  MainViewController.swift
//  Twitter
//
//  Created by Adam Crabtree on 2/22/15.
//  Copyright (c) 2015 Adam Crabtree. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    lazy var refreshControl = UIRefreshControl()
    var tweets = [Tweet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(self.refreshControl, atIndex:0)
        
        self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 85
        
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweet = sender as? Tweet, dc = segue.destinationViewController as? ComposeViewController {
            dc.tweet = tweet
        }
        
        
        if let tweet = sender as? Tweet, dc = segue.destinationViewController as? TweetViewController {
            dc.tweet = tweet
        }
    }
    
    
    // MARK: - Table
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let tweet = self.tweets[indexPath.row]
        
        cell.nameLabel.text = tweet.user?.name
        cell.screennameLabel.text = tweet.user?.screenname
        cell.contentLabel.text = tweet.text
        if let imageUrlString = tweet.user?.profileImageUrl, let imageUrl = NSURL(string: imageUrlString) {
            cell.thumbImage.setImageWithURL(imageUrl)
        }
        
        
        cell.replyButton.addTarget(self, action: "replyTapped:", forControlEvents: .TouchUpInside)
        cell.retweetButton.addTarget(self, action: "retweetTapped:", forControlEvents: .TouchUpInside)
        cell.favoriteButton.addTarget(self, action: "favoriteTapped:", forControlEvents: .TouchUpInside)
        
        if let createdAt = tweet.createdAt {
            println(createdAt)
            let now = NSDate()
            let distanceBetweenDates = now.timeIntervalSinceDate(createdAt)
            let hoursBetweenDates = Int(distanceBetweenDates / 3600)
            
            if hoursBetweenDates < 24 {
                cell.timeLabel.text = "\(hoursBetweenDates)h"
            } else {
                var formatter = NSDateFormatter()
                formatter.dateFormat = "M/d/Y"
                formatter.timeZone = NSTimeZone(abbreviation: "PST")
                cell.timeLabel.text = formatter.stringFromDate(createdAt)
            }
        }
        
        if tweet.retweeted == true {
            cell.retweetButton.setImage(UIImage(named:"1040-checkmark-toolbar-selected"), forState: .Normal)
            
        }
        
        
        if tweet.favorited == true {
            cell.favoriteButton.setImage(UIImage(named:"726-star-toolbar-selected"), forState: .Normal)
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("tweetDetails", sender:self.tweets[indexPath.row])
    }

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    func replyTapped(sender: UIButton!) {
        let cell = sender.superview?.superview as! TweetCell
        if let indexPath = self.tableView.indexPathForCell(cell) {
            let tweet = self.tweets[indexPath.row]
            
            self.performSegueWithIdentifier("composeSegue", sender:tweet)
        }
        
    }
    
    func retweetTapped(sender: UIButton!) {
        println("retweetTapped")
        let cell = sender.superview?.superview as! TweetCell
        if let indexPath = self.tableView.indexPathForCell(cell) {
            let tweet = self.tweets[indexPath.row]
            TwitterClient.sharedInstance.retweetWithCompletion(tweet.id!) {
                (error) -> () in
                println(error)
                cell.retweetButton.setImage(UIImage(named:"1040-checkmark-toolbar-selected"), forState: .Normal)
            }
        }
    }
    
    func favoriteTapped(sender: UIButton!) {
        let cell = sender.superview?.superview as! TweetCell
        if let indexPath = self.tableView.indexPathForCell(cell) {
            let tweet = self.tweets[indexPath.row]
            TwitterClient.sharedInstance.favoriteWithCompletion(tweet.id!, completion: { (error) -> () in
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TweetCell
                cell.favoriteButton.setImage(UIImage(named:"726-star-toolbar-selected"), forState: .Normal)
            })
        }
    }

    func onRefresh() {
        //        println("onRefresh")
        loadData { self.refreshControl.endRefreshing() }
    }
    
    func loadData(completionHandler: ()->() = {}) {
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil, completion: { (tweets, error) -> () in
            self.tweets = tweets ?? []
            self.tableView.reloadData()
            completionHandler()
        })
    }
}

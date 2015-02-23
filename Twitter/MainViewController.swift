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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
        
        if let createdAt = tweet.createdAt {
            println(createdAt)
            let now = NSDate()
            let distanceBetweenDates = now.timeIntervalSinceDate(createdAt)
            let hoursBetweenDates = Int(distanceBetweenDates / 3600)

//            let calendar = NSCalendar.currentCalendar()
//            let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
//            calendar.setTimeZone(NSTimeZone.timeZoneWithName("PST"))
//            let travelDateTimeComponents = calendar.components((.HourCalendarUnit | .MinuteCalendarUnit), fromDate:tweet.createdAt!)
//            let hours = NSString(format: "%02i", travelDateTimeComponents.hour)
//            let comp = calendar.components((.HourCalendarUnit | .MinuteCalendarUnit), fromDate: tweet.createdAt!)
            if hoursBetweenDates < 24 {
                cell.timeLabel.text = "\(hoursBetweenDates)h"
            } else {
                var formatter = NSDateFormatter()
                formatter.dateFormat = "M/d/Y"
                formatter.timeZone = NSTimeZone(abbreviation: "PST")
                cell.timeLabel.text = formatter.stringFromDate(createdAt)
            }
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
        //        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //
        //        let vc = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        //        vc.data = self.data?["movies"][indexPath.row]
        //        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? MovieCell {
        //            vc.thumbnail = cell.movieImage?.image
        //        }
        //
        //        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
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

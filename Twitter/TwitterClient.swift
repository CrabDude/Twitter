//
//  TwitterClient.swift
//  Twitter
//
//  Created by Adam Crabtree on 2/22/15.
//  Copyright (c) 2015 Adam Crabtree. All rights reserved.
//

import UIKit

let twitterConsumerKey = "k9kHb2yVjlNPZd6lVBtVQvkNJ"
let twitterConsumerSecret = "J1s5lJFEF3z0rFFoafwMHZJrFnAjKVbQLcgAh88EpBjib9GyZJ"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")!

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
   
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        self.loginCompletion = completion
        
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken) -> Void in
            println("got request token")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(authURL)
            }) { (error) -> Void in
                println("request token fail")
        }
    }
    
    func homeTimelineWithCompletion(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        self.GET("1.1/statuses/home_timeline.json", parameters: ["exclude_replies": "false"], success: { (operation, response) -> Void in
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        }) { (operation, error) -> Void in
            completion(tweets: nil, error: error)
        }
    
    }
    
    func openURL(url: NSURL) {
        let credentials = BDBOAuth1Credential(queryString: url.query!)
        println(credentials)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: credentials, success: { (accessToken) -> Void in
            println("Got access token!")
            self.requestSerializer.saveAccessToken(accessToken)
            self.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation, response) -> Void in
                var user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
            }) { (operation, error) -> Void in
                self.loginCompletion?(user: nil, error: error)
            }
        }) { (error) -> Void in
            self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func tweetWithCompletion(params: [String:String], completion: (error: NSError?) -> ()) {
        self.POST("1.1/statuses/update.json", parameters: params, success: { (request, data) -> Void in
            completion(error: nil)
        }) { (request, error) -> Void in
            completion(error: error)
        }
    }
    
    func favoriteWithCompletion(id: String, completion: (error: NSError?) -> ()) {
        self.POST("1.1/favorites/create.json", parameters: ["id": id], success: { (request, data) -> Void in
            completion(error: nil)
        }) { (request, error) -> Void in
            completion(error: error)
        }
    }
    
    func retweetWithCompletion(id: String, completion: (error: NSError?) -> ()) {
        self.POST("1.1/statuses/retweet/\(id).json", parameters: nil, success: { (request, data) -> Void in
            completion(error: nil)
            }) { (request, error) -> Void in
                completion(error: error)
        }
    }
    
}

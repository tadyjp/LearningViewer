//
//  Tweet.swift
//  TableSwipe
//
//  Created by tady on 7/14/14.
//  Copyright (c) 2014 tady. All rights reserved.
//

import Foundation
import Accounts
import Social

class Tweet : Printable {
    var text: String
    var positive: Bool
    
    var vector: Dictionary<String, Double> {
    var dic: Dictionary<String, Double> = [:]
        for seg in self.segments() {
            dic[seg] = 1.0
        }
        return dic
    }
    
    init(text: String) {
        self.text = text
        self.positive = true
    }
    
    var description: String {
        return "Tweet<text:\"\(self.text)\">"
    }
    
    func segments() -> [String] {
        let segmenter: TinySegmenter = TinySegmenter()
        var segments = [String]()

        for item in segmenter.segment(self.text) as [AnyObject] {
            segments.append(item as String)
        }

        return segments
    }
    
    class func loadTweets(callback: ([Tweet] -> ())) {
        var account: ACAccountStore = ACAccountStore()
        let accountType: ACAccountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil, completion: {
            (granted: Bool, error: NSError!) in
            
            if granted {
                println("Account access successed.")
                
                var arrayOfAccounts = account.accountsWithAccountType(accountType) as [ACAccount]
                println("arrayOfAccounts: \(arrayOfAccounts)")
                
                if arrayOfAccounts.count > 0 {
                    let twitterAccount: ACAccount = arrayOfAccounts[arrayOfAccounts.endIndex - 1]
                    println("twitterAccount: \(twitterAccount)")
                    
                    let requestURL: NSURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                    
                    let postRequest: SLRequest = SLRequest(
                        forServiceType: SLServiceTypeTwitter,
                        requestMethod: SLRequestMethod.GET,
                        URL: requestURL,
                        parameters: nil)
                    
                    postRequest.account = twitterAccount
                    
                    postRequest.performRequestWithHandler({
                        (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) in
                        let responseArray = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as NSMutableArray
                        
                        var dataSource = [Tweet]()
                        for item in responseArray {
                            dataSource.append(Tweet(text: item["text"] as String))
                        }
                        
                        callback(dataSource)
                        })
                }
            } else {
                println("Account access failure.")
            }
            
            })
    }
    
}
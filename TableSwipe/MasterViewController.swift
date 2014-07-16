//
//  MasterViewController.swift
//  TableSwipe
//
//  Created by tady on 7/14/14.
//  Copyright (c) 2014 tady. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var dataSource = [Tweet]()
    var arow: Arow = Arow(r: 0.1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        //        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //        self.navigationItem.rightBarButtonItem = addButton
        
        
        let refresh: UIRefreshControl = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: "updateTimeLine", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        self.updateTimeLine()
    }
    
    func stopRefresh() {
        self.refreshControl.endRefreshing()
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        var swipePositive: Bool = false
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
                swipePositive = true
            case UISwipeGestureRecognizerDirection.Left:
                println("Swiped left")
            default:
                break
            }
        }
        
        let location: CGPoint = gesture.locationInView(self.tableView)
        let swipedIndexPath: NSIndexPath = tableView.indexPathForRowAtPoint(location)
        
        let swipedTweet = self.dataSource[swipedIndexPath.row]
        
        println("swipedTweet: \(swipedTweet)")
        
        arow.update(FeatureVector(vector: swipedTweet.vector), label: swipePositive)
        
        arow.save()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let object = dataSource[indexPath.row]
            (segue.destinationViewController as DetailViewController).detailItem = object
        }
    }
    
    // #pragma mark - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let tweet = dataSource[indexPath.row] as Tweet
        cell.textLabel.text = tweet.text
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func refreshTable() {
        self.stopRefresh()
        self.tableView.reloadData()
    }
    
    func updateTimeLine() {
        Tweet.loadTweets({
            (dataSource: [Tweet]) in
            self.dataSource = dataSource
            println("self.dataSource: \(self.dataSource)")
            
            if self.dataSource.count != 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshTable()
                    })
            }
            })
        
    }
}


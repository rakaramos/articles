//
//  ViewController.swift
//  Pocket
//
//  Created by Wojciech Lukaszuk on 24/06/14.
//  Copyright (c) 2014 Wojciech Lukaszuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var articleTableView : UITableView!
    var pocketRefreshControl = PocketRefreshControl()
    var titles: [String] = ["Introduction to MVVM", "Avoiding Singleton Abuse", "Behaviours in iOS Apps", "Sublassing",
        "Animations Explained", "Animating Custom Layer Properties", "View Layer Synergy", "Animating Collection Views",
        "Data Synchronization", "iCloud and Core Data", "A Sync Case Study", "NSString and Unicode", "Lighter View Controllers",
        "Custom Formatters", "Linguistic Tagging", "Value Objects", "Core Data Overview", "Fetch Requests", "Custom Controls"]
    var changes = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.pocketRefreshControl.attachToScrollView(articleTableView,
            refreshAction: {
                [weak self] in
                self!.loadArticles()
            }, updateAction: {
                [weak self] in
                self!.refreshArticlesList()
            })
    }
    
    func loadArticles() -> ()
    {
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            [weak self] in
            let index = arc4random_uniform(UInt32(self!.titles.count))
            let title = self!.titles[Int(index)]
            self!.changes.insert(title, atIndex: 0)
            self!.pocketRefreshControl.stopRefreshAnimation()
            }
        )
    }
    
    func refreshArticlesList()
    {
        self.articleTableView.beginUpdates()
        self.titles.insert(self.changes[0], atIndex: 0)
        self.changes.removeAll(keepCapacity: false)
        self.articleTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)],
            withRowAnimation: UITableViewRowAnimation.Fade)
        self.articleTableView.endUpdates()
    }
    
    // pragma mark - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView : UIScrollView)
    {
        pocketRefreshControl.scrollViewDidScroll()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool)
    {
        pocketRefreshControl.scrollViewDidEndDragging()
    }
    
    // pragma mark - helpers
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return titles.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        var cell: ArticleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ArticleTableViewCell") as ArticleTableViewCell
        cell.titleLabel.text = titles[indexPath.row]
        
        return cell
    }
}

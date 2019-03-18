//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Russelle Pineda on 3/9/19.
//  Copyright © 2019 Russelle Pineda. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

//need UITableViewDelegate, UITableViewDataSource
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    
    var showsCommentBar = false //so comment bar is not shown on default
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    let refreshControl = UIRefreshControl() //refreshcontrol
    
    //will explore this
    @IBAction func onLogoutButton(_ sender: Any) {
        
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "loginViewController")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate //needed cast to AppDelegate because window in subclass
        
        delegate.window?.rootViewController = loginViewController
    }
    
    
    @objc func keyBoardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil //clear textfield everytime it gets dissmiedd
        showsCommentBar = false
        becomeFirstResponder()
        
    }
    
    //change selection, on right side "image view" panel,  to "none" so when table view is clicked, it doesnt turn gray
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self //have MessageInputBarDelegate on top of code
        loadFeed()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive //pulls down keyboard by dragging it down
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        refreshControl.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
        // Do any additional setup after loading the view.
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    //tableview refreshed
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadFeed()
        
        /*
         //query                        //for us its "Posts"
         let query = PFQuery(className:"Posts")
         query.includeKey("author")
         query.limit = 20 //ex: last 20
         
         //array of objects
         query.findObjectsInBackground { (posts, error) in
         if posts != nil {
         self.posts = posts! //put data in array/ store data
         self.tableView.reloadData() //tell tableview to reload itself so it calls function again
         }
         }
         */
    }
    
    
    var numberOfFeed: Int!
    
    @objc func loadFeed(){
        
        numberOfFeed = 40
        
        //query                        //for us its "Posts"
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = numberOfFeed //ex: last 20
        
        //array of objects
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts! //put data in array/ store data
                self.tableView.reloadData() //tell tableview to reload itself so it calls function again
                
                self.refreshControl.endRefreshing() //ends refresh(infinte spinning "load wheel")usually after reloadData() func
            }
        }
    }
    
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments") //forkey: comments is madeu up

        //saving the post
        selectedPost.saveInBackground { (success, error) in
            if (success){
                print("Comment saved!")
            }
            else{
                print("Error saving comment!")
            }
        }
        
        tableView.reloadData() //to refresh
        
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil //clear textfield everytime it gets dissmiedd
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func loadMoreFeed(){
        
        let query = PFQuery(className:"Posts")
    
        numberOfFeed = numberOfFeed + 5
        
        query.includeKey("author")
        query.limit = numberOfFeed
        
      
        
        //array of objects
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts! //put data in array/ store data
                self.tableView.reloadData() //tell tableview to reload itself so it calls function again
                
            }
        }
        
        print("Loading more feed!")
        print(posts.count)
        
    }
    
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        if indexPath.row + 1 == posts.count {
            loadMoreFeed()
            print(indexPath.row)
        }
    }
    */
    
    
    //functions required for dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 0
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []  //?? is nil coalescing operator
        
        //return comments.count + 1
        return comments.count + 2 //because of comment bar added
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []  //?? is nil coalescing operator
        
        if indexPath.row == 0 {                                                        //identifier on cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
            let user = post["author"] as! PFUser
            cell.userNameLabel.text = user.username
        
                                        //called it "caption" which shows up on server
            cell.captionLabel.text = post["caption"] as! String
        
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)
        
            cell.photoView.af_setImage(withURL: url!)
        
            return cell
        }
        else if indexPath.row <= comments.count { //for comments section
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1] //zeroith comment. if zero, that is the post
            cell.nameLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCommentCell")!
            
            return cell
        }
    }
    
    
    //comment feature
    //bottom constraints are always greater than or equal to, because of dynamic height sizing with labels(ex: long comments vs short comments)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section] //was .row
        
        //let comment = PFObject(className: "Comment") //create Comment object   this is wrong
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        if indexPath.row == comments.count + 1 { //if last cell, show comment
            showsCommentBar = true
            becomeFirstResponder()
            
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
        
//        comment["text"] = "this is a random text"
//        comment["post"] = post
//        comment["author"] = PFUser.current()!
//
//        post.add(comment, forKey: "comments") //forkey: comments is madeu up
//
//        //saving the post
//        post.saveInBackground { (success, error) in
//            if (success){
//                print("Comment saved!")
//            }
//            else{
//                print("Error saving comment!")
//            }
//        }
    }
    

    /*
    // MARK: - Navigation
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

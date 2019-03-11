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

//need UITableViewDelegate, UITableViewDataSource
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    
    //tableview refreshed
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
    }
    
    //functions required for dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 0
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                                                                //identifier on cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

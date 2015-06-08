//
//  ViewController.swift
//  QMMedica
//
//  Created by QiMENG on 15/6/8.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var dataArray:Array<Model> = []
    var pageInt:Int = 1
    
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mainTableView.tableFooterView = UIView()
        
        SVProgressHUD.showWithStatus("努力加载...", maskType: SVProgressHUDMaskType.Black)
        Service.medicaPage(1, withBlock: { (list, error) -> Void in
            self.dataArray += list as! Array<Model>
            
            self.mainTableView.reloadData()
            SVProgressHUD.dismiss()
            ++self.pageInt
        })
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return self.dataArray.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == self.dataArray.count
        {
            var cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath) as! UITableViewCell
            
            return cell
        }
        else
        {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
            
            var m = self.dataArray[indexPath.row]
            
            cell.textLabel?.text = m.title
            
            return cell
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.mainTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == dataArray.count {
            
            SVProgressHUD.showWithStatus("加载更多...", maskType: SVProgressHUDMaskType.Black)
            
            Service.medicaPage(Int32(self.pageInt)) { (array, error) -> Void in
                
                if self.dataArray.count > 0 && array.count > 0 {
                    
                    let model1 = self.dataArray.last as Model!
                    let model2 = array.last as! Model
                    
                    if model1.href == model2.href {
                        
                        SVProgressHUD.showErrorWithStatus("没有更多了")
                        return
                    }
                }
                
                self.dataArray += array as! Array<Model>
                self.mainTableView.reloadData()
                SVProgressHUD.dismiss()
                ++self.pageInt
                
            }
            
        }
        else {
            let model = dataArray[indexPath.row] as Model
            
            
            
            self.performSegueWithIdentifier("DetaileViewController", sender: model)
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "DetaileViewController" {
            
            var ctrl = segue.destinationViewController as! DetaileViewController
            ctrl.infoModel = sender as? Model
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


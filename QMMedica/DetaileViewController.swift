//
//  DetaileViewController.swift
//  QMMedica
//
//  Created by Lin on 15/6/9.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

import UIKit

class DetaileViewController: UIViewController {

    var infoModel:Model?
    @IBOutlet weak var mainText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = infoModel?.title
        
        self.mainText.text = infoModel?.info
        
        
//        SVProgressHUD.showWithStatus("努力加载...", maskType: SVProgressHUDMaskType.Black)
//        Service.info(infoModel, withBlock: { (aModel, error) -> Void in
//            
//            var model = aModel as! Model
//            
//            self.mainText.text = model.info
//            
//            SVProgressHUD.dismiss()
//        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

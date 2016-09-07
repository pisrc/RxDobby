//
//  ViewController.swift
//  RxDobbyExample
//
//  Created by ryan on 9/7/16.
//  Copyright © 2016 kimyoungjin. All rights reserved.
//

import UIKit
import RxSwift
import RxDobby
class ViewController: UIViewController {

    @IBOutlet weak var area1: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let ob = Observable<Int>.interval(1.0, scheduler: MainScheduler.instance).take(5)
        DIActivityIndicatorView(centerAtView: area1, style: UIActivityIndicatorViewStyle.WhiteLarge).bindTo(ob)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


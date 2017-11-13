//
//  ViewController.swift
//  VendorSignin
//
//  Created by lzc1104 on 11/13/2017.
//  Copyright (c) 2017 lzc1104. All rights reserved.
//

import UIKit
import VendorSignin

class VendorSigninFucker: VendorSigninManager {
    static let shared = VendorSigninFucker()
}

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.register()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func register() {
        self.navigationItem.title = "略缩图为图片"
        let wechatAccount = VendorSigninManager.Account.weChat(
            appID: "wxd5303f3621dd900d",
            appKey: "a11e59226e19691a2f3df68fdec086d3"
        )
        
        let qqAccount = VendorSigninManager.Account.qq(appID: "1105338639")
        
        let weiboAccount = VendorSigninManager.Account.weibo(
            appID: "379457724",
            appKey: "3ed1d2f34909009dda68e379e1898150",
            redirectURL: "http://sns.whalecloud.com/sina2/callback"
        )
        
        let accounts: [VendorSigninManager.Account] = [wechatAccount,qqAccount,weiboAccount]
        accounts.forEach(VendorSigninFucker.shared.registerAccount(_:))
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            VendorSigninFucker.shared.oauth(for: .weChat, acompletionHandler: { (result) in
                switch result {
                case .success(let info):
                    print(info)
                    break
                case .error(_):
                    break
                }
            })
            break
        case 1:
            VendorSigninFucker.shared.oauth(for: .qq, acompletionHandler: { (result) in
                switch result {
                case .success(let info):
                    print(info)
                    break
                case .error(_):
                    break
                }
            })
        case 2:
            VendorSigninFucker.shared.oauth(for: .weibo, acompletionHandler: { (result) in
                switch result {
                case .success(let info):
                    print(info)
                    break
                case .error(_):
                    break
                }
            })
            break
        default:
            break
        }
    }

}


//
//  VendorSigninManager.swift
//  VendorSignin
//
//  Created by lzc1104 on 2017/11/13.
//

import UIKit
import MonkeyKing

open class VendorSigninManager {
    public init() {}
    var accountSet = Set<Account>()
    
    public enum Result<T> {
        case success(T)
        case error(Swift.Error)
    }
    
    
    public enum Error: Swift.Error {
        case invalidUserInfo
        case unregconize
    }
    
    public struct Info {
        
        public enum Gender: Int {
            case male = 1
            case female = 2
            case none = 0
        }
        
        var accessToken: String = ""
        var openId: String = ""
        var avatar: String = ""
        var gender: Gender = .none
    }
    
    public enum SupportedPlatform {
        case qq
        case weChat
        case weibo
        
        public var isAppInstalled: Bool {
            switch self {
            case .weChat:
                return VendorSigninManager.canOpenURL(urlString: "weixin://")
            case .qq:
                return VendorSigninManager.canOpenURL(urlString: "mqqapi://")
            case .weibo:
                return VendorSigninManager.canOpenURL(urlString: "weibosdk://request")
            }
        }
        
        func asMonkeyKingPlatform() -> MonkeyKing.SupportedPlatform {
            switch self {
            case .weibo:
                return MonkeyKing.SupportedPlatform.weibo
            case .weChat:
                return MonkeyKing.SupportedPlatform.weChat
            case .qq:
                return MonkeyKing.SupportedPlatform.qq
            }
        }
    }
    
    public enum Account: Hashable {
        case weChat(appID: String, appKey: String?)
        case qq(appID: String)
        case weibo(appID: String, appKey: String, redirectURL: String)
        
        public var isAppInstalled: Bool {
            switch self {
            case .weChat:
                return VendorSigninManager.SupportedPlatform.weChat.isAppInstalled
            case .qq:
                return VendorSigninManager.SupportedPlatform.qq.isAppInstalled
            case .weibo:
                return VendorSigninManager.SupportedPlatform.weibo.isAppInstalled
                
            }
        }
        
        public var appID: String {
            switch self {
            case .weChat(let appID, _):
                return appID
            case .qq(let appID):
                return appID
            case .weibo(let appID, _, _):
                return appID
            }
        }
        
        public var hashValue: Int {
            return appID.hashValue
        }
        
        public var canWebOAuth: Bool {
            switch self {
            case .qq, .weibo, .weChat:
                return true
            }
        }
        
        public static func ==(lhs: Account, rhs: Account) -> Bool {
            return lhs.appID == rhs.appID
        }
        
        func asMonkeyKingAccount() -> MonkeyKing.Account {
            switch self {
            case .weChat(let appID, let appKey):
                return MonkeyKing.Account.weChat(appID: appID, appKey: appKey)
            case .qq(let appID):
                return MonkeyKing.Account.qq(appID: appID)
            case .weibo(let appID, let appKey, let redirectURL):
                return MonkeyKing.Account.weibo(appID: appID, appKey: appKey, redirectURL: redirectURL)
            }
        }
        
    }
    
    open func registerAccount(_ account: Account) {
        guard account.isAppInstalled || account.canWebOAuth else { return }
        for oldAccount in self.accountSet {
            switch oldAccount {
            case .weChat:
                if case .weChat = account { self.accountSet.remove(oldAccount) }
            case .qq:
                if case .qq = account { self.accountSet.remove(oldAccount) }
            case .weibo:
                if case .weibo = account { self.accountSet.remove(oldAccount) }
            }
        }
        self.accountSet.insert(account)
        MonkeyKing.registerAccount(account.asMonkeyKingAccount())
    }
    
    class func canOpenURL(urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    public typealias OAuthCompletionHandler = ((VendorSigninManager.Result<Info>)) -> Void
    public func oauth(for platform: SupportedPlatform,acompletionHandler: @escaping OAuthCompletionHandler) {
        
        var scope: String? = nil
        switch platform {
        case .weChat,.weibo:
            break
        case .qq:
            scope = "get_user_info"
        }
        MonkeyKing.oauth(for: platform.asMonkeyKingPlatform(),scope: scope) { (dict, resp, error) in
            switch platform {
            case .weChat:
                guard
                    let token = dict?["access_token"] as? String,
                    let openID = dict?["openid"] as? String else {
                        acompletionHandler(.error(Error.invalidUserInfo))
                        return
                }
                
                let userInfoAPI = "https://api.weixin.qq.com/sns/userinfo"
                
                let parameters = [
                    "openid": openID,
                    "access_token": token
                ]
                SimpleNetworking.sharedInstance.request(userInfoAPI, method: .get, parameters: parameters, completionHandler: { (userInfo, _, _) in
                    
                    guard var userInfo = userInfo else {
                        acompletionHandler(.error(Error.invalidUserInfo))
                        return
                    }
                    let token: String = (userInfo["access_token"] as? String) ?? ""
                    let openId: String = (userInfo["openid"] as? String) ?? ""
                    let avatar: String = (userInfo["headimgurl"] as? String) ?? ""
                    
                    let gender: Info.Gender = {
                        if let value = (userInfo["sex"] as? Int),
                            let gender = Info.Gender.init(rawValue: value){
                            return gender
                        }
                        return .none
                        
                    }()
                    
                    let info = Info.init(accessToken: token, openId: openId, avatar: avatar, gender: gender)
                    acompletionHandler(.success(info))
                })
                break
            case .weibo:
                break
            case .qq:
                break
            }
        }
        
    }
    
    public func handleOpenURL(_ url: URL) -> Bool {
        guard let urlScheme = url.scheme else { return false }
        // WeChat
        if urlScheme.hasPrefix("wx") {
            let urlString = url.absoluteString
            // OAuth
            if urlString.contains("state=Weixinauth") {
                return MonkeyKing.handleOpenURL(url)
            }
           
            // OAuth Failed
            if urlString.contains("platformId=wechat") && !urlString.contains("state=Weixinauth") {
                return MonkeyKing.handleOpenURL(url)
            }
            return false
        }
        
        // QQ OAuth
        if urlScheme.hasPrefix("tencent") {
            return MonkeyKing.handleOpenURL(url)
        }
        // Weibo
        if urlScheme.hasPrefix("wb") {
            let items = UIPasteboard.general.items
            var results = [String: Any]()
            for item in items {
                for (key, value) in item {
                    if let valueData = value as? Data, key == "transferObject" {
                        results[key] = NSKeyedUnarchiver.unarchiveObject(with: valueData)
                    }
                }
            }
            guard
                let responseInfo = results["transferObject"] as? [String: Any],
                let type = responseInfo["__class"] as? String else {
                    return false
            }
            guard let _ = responseInfo["statusCode"] as? Int else {
                return false
            }
            switch type {
            // OAuth
            case "WBAuthorizeResponse":
                return MonkeyKing.handleOpenURL(url)
            // Share
            case "WBSendMessageToWeiboResponse":
                return false
            default:
                break
            }
        }
        
        return false
    }
    
}

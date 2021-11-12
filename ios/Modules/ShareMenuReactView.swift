//
//  ShareMenuReactView.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 28/07/2020.
//

import MobileCoreServices
import React

public protocol ReactShareViewDelegate {
    func loadExtensionContext() -> NSExtensionContext

    func openApp()
    
    func dismissViewNow()
}
public let NO_EXTENSION_CONTEXT_ERROR = "No extension context attached"
public let DISMISS_SHARE_EXTENSION_WITH_ERROR_CODE = 1
public let NO_DELEGATE_ERROR = "No ReactShareViewDelegate attached"
public let COULD_NOT_FIND_ITEM_ERROR = "Couldn't find item attached to this share"
public let DATA_KEY =  "data"
public let MIME_TYPE_KEY =  "mimeType"

@objc(ShareMenuReactView)
public class ShareMenuReactView: NSObject {
    static var viewDelegate: ReactShareViewDelegate?

    @objc
    static public func requiresMainQueueSetup() -> Bool {
        return false
    }

    public static func attachViewDelegate(_ delegate: ReactShareViewDelegate!) {
        guard (ShareMenuReactView.viewDelegate == nil) else { return }

        ShareMenuReactView.viewDelegate = delegate
    }

    public static func detachViewDelegate() {
        ShareMenuReactView.viewDelegate = nil
    }

    @objc(dismissExtension:)
    func dismissExtension(_ error: String?) {
        print("dismissExtension")
        guard let extensionContext = ShareMenuReactView.viewDelegate?.loadExtensionContext() else {
            print("Error: \(NO_EXTENSION_CONTEXT_ERROR)")
            return
        }
        print("B")
        if error != nil {
            let exception = NSError(
                domain: Bundle.main.bundleIdentifier!,
                code: DISMISS_SHARE_EXTENSION_WITH_ERROR_CODE,
                userInfo: ["error": error!]
            )
            print("cancelRequest B")
            extensionContext.cancelRequest(withError: exception)
            ShareMenuReactView.viewDelegate?.dismissViewNow()
            return
        }
        print("completeRequest B")
        extensionContext.completeRequest(returningItems: [], completionHandler: nil)
        ShareMenuReactView.viewDelegate?.dismissViewNow()
    }

    @objc
    func openApp() {
        guard let viewDelegate = ShareMenuReactView.viewDelegate else {
            print("Error: \(NO_DELEGATE_ERROR)")
            return
        }

        viewDelegate.openApp()
    }

    @objc(data:reject:)
func data(_
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock) {
    guard let extensionContext = ShareMenuReactView.viewDelegate?.loadExtensionContext() else {
        print("Error: \(NO_EXTENSION_CONTEXT_ERROR)")
        return
    }
    var urlFound = "Nonefound";
    if let item = extensionContext.inputItems.first as? NSExtensionItem {
        if let itemProvider = item.attachments?.first as? NSItemProvider {
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                    if let shareURL = url as? NSURL {
                        // send url to server to share the link
                        print("AWESOME URL HERE",shareURL)
                    urlFound = shareURL.absoluteString ?? "StillNoneFound!"
                    }
                    resolve([MIME_TYPE_KEY: "text/plain", DATA_KEY: urlFound])
                })
            }
        }
    }
}


}

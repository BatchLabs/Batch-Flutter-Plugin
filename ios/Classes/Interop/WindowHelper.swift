import Foundation

// Swift port of Batch's BAWindowHelper
internal struct WindowHelper {
    /// Try to get the keyWindow if the app is on screen. Handles UIScene apps.
    static var keyWindow: UIWindow? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            window = keyWindowFromScene
        }
        return window ?? UIApplication.shared.keyWindow
    }
    
    /// The view controller that we think is the one currently visible (as in not covered by another one)
    /// It should be the most appropriate one to display anything over.
    static var topViewController: UIViewController? {
        return WindowHelper.keyWindow?.rootViewController
    }
    
    @available(iOS 13.0, *)
    private static var keyWindowFromScene: UIWindow? {
        // Don't use activeWindowScene as we want to loop on all scenes until we get what we want
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive, let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    if window.isKeyWindow {
                        return window
                    }
                }
            }
        }
        return nil
    }
}

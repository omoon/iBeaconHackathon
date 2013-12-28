class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible

    @window.tintColor = "#738f56".to_color
    UINavigationBar.appearance.barTintColor = "#738f56".to_color
    UINavigationBar.appearance.tintColor = UIColor.whiteColor
    UINavigationBar.appearance.titleTextAttributes = {NSForegroundColorAttributeName => UIColor.whiteColor}

    UIApplication.sharedApplication.setStatusBarStyle UIStatusBarStyleLightContent

    # This is our new line!
    controller = MainController.alloc.initWithNibName(nil, bundle: nil)
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(controller)


    true
  end
end

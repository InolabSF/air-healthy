/// MARK: - AIRNavigationController
class AIRNavigationController: UINavigationController {


    /// MARK: - initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    /// MARK: - destruction

    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()
//        // notification
//        NSNotificationCenter.defaultCenter().addObserver(
//            self,
//            selector: Selector("didUpdateSensorValues:"),
//            name: AIRNotificationCenter.DidUpdateSensorValues,
//            object: nil
//        )
    }


//    /**
//     * get sensor datas
//     * @param notification NSNotification
//     **/
//    func didUpdateSensorValues(notificatoin: NSNotification) {
//        self.popToRootViewControllerAnimated(true)
//    }

}

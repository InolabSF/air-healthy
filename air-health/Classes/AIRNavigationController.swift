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
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()
    }
}

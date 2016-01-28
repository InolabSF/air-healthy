/// MARK: - AIRLoadingView
class AIRLoadingView: UIView {

    /// MARK: - property

    var indicatorView: BLMultiColorLoader!


    /// MARK: - initialization

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initIndicatorView()
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initIndicatorView()
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initIndicatorView()
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }

    /// MARK: - event listener


    /// MARK: - public api

    func startAnimation() {
        if self.superview == nil {
            UIApplication.sharedApplication().keyWindow!.addSubview(self)
        }
        UIApplication.sharedApplication().keyWindow!.bringSubviewToFront(self)

        self.hidden = false
        self.indicatorView.startAnimation()
    }

    func stopAnimation() {
        self.hidden = true
        self.indicatorView.stopAnimation()
    }


    /// MARK: - private api

    func initIndicatorView() {
        self.indicatorView = BLMultiColorLoader(frame: CGRectMake(0, 0, 48, 48))
        self.indicatorView.center = self.center
        self.indicatorView.colorArray = [
            UIColor.redColor(),
            UIColor.purpleColor(),
            UIColor.greenColor(),
            UIColor.blueColor(),
        ]
        self.addSubview(self.indicatorView)
    }

}

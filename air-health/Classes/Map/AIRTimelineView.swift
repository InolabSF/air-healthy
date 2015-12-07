// MARK: - AIRTimelineViewDelegate
@objc protocol AIRTimelineViewDelegate {

    /**
     * called when button is touched up inside
     * @param timelineView AIRTimelineView
     * @param closeButton UIButton
     */
    func touchedUpInside(timelineView timelineView: AIRTimelineView, closeButton: UIButton)

    /**
     * called when control value changed
     * @param timelineView AIRTimelineView
     * @param control GradientSlider
     */
    func valueChanged(timelineView timelineView: AIRTimelineView, control: GradientSlider)

}



/// MARK: - AIRTimelineView
class AIRTimelineView: UIView {

    /// MARK: - property

    @IBOutlet weak var delegate: AnyObject?

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var timeSliderParentView: UIView!
    @IBOutlet weak var timeSliderTitleView: UIView!
    @IBOutlet weak var timeSliderContentView: UIView!
    @IBOutlet weak var timeSliderView: UIView!
    @IBOutlet weak var timelineLineChartBackgroundView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var redView: UIView!
    var timelineLineChartView: JTChartView?
    @IBOutlet weak var timeIndicatorView: UIView!
    @IBOutlet weak var timeSlider: GradientSlider!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setUp()
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        if button == self.closeButton {
            if self.delegate != nil {
                (self.delegate as! AIRTimelineViewDelegate).touchedUpInside(timelineView: self, closeButton: button)
            }
        }
        else if button == self.dateButton {
        }
    }

    /**
     * called when control value changed
     * @param control UIControl
     **/
    @IBAction func valueChanged(control control: UIControl) {
        if control == self.timeSlider {
            (self.delegate as! AIRTimelineViewDelegate).valueChanged(timelineView: self, control: self.timeSlider)
        }
    }


    /// MARK: - public api

    /**
     * show or hide time slider
     * @param hidden Bool
     * @param animationHandler blocks
     * @param completionHandler blocks
     **/
    func toggleTimeSlider(hidden hidden: Bool, animationHandler: () -> Void, completionHandler: () -> Void) {
        // position
        let hiddenDestination = CGRectMake(
            self.timeSliderParentView.frame.origin.x, self.frame.height - self.timeSliderParentView.frame.height,
            self.timeSliderParentView.frame.width, self.timeSliderParentView.frame.height
        )
        let shownDestination = CGRectMake(
            self.timeSliderParentView.frame.origin.x, self.frame.height - self.timeSliderView.frame.height,
            self.timeSliderParentView.frame.width, self.timeSliderParentView.frame.height
        )

        // start setting
        self.timeSliderView.hidden = false
        self.timeSliderView.alpha = (hidden) ? 1 : 0
        self.timeSliderParentView.frame = (hidden) ? shownDestination : hiddenDestination
        self.timeLabel.hidden = false
        self.timeLabel.alpha = (hidden) ? 1 : 0

        // animation
        UIView.animateWithDuration(
            (hidden) ? 0.20 : 0.25,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                animationHandler()
                self.timeSliderView.alpha = (hidden) ? 0 : 1
                self.timeSliderParentView.frame = (hidden) ? hiddenDestination : shownDestination
                self.timeLabel.alpha = (hidden) ? 0 : 1
            },
            completion: { [unowned self] finished in
                completionHandler()
                self.timeSliderView.hidden = hidden
                self.timeLabel.hidden = hidden
            }
        )
    }

    /**
     * set timeline value
     * @param time String
     * @param color UIColor
     **/
    func setTimeline(time time: String, color: UIColor) {
        // time
        self.timeLabel.text = time
        // color
        self.timeLabel.textColor = color

        self.timeIndicatorView.frame = CGRectMake(
            1.0 + (self.timelineLineChartBackgroundView.frame.width - 3.0) * self.timeSlider.value / self.timeSlider.maximumValue, self.timeIndicatorView.frame.origin.y,
            self.timeIndicatorView.frame.width, self.timeIndicatorView.frame.height
        )
    }

    /**
     * set line chart
     * @param lineChart line chart
     * @param valuesPerMinute [Double]
     * @param sensorBasements [Double]
     * @param title String
     **/
    func setLineChart(passes passes: [CLLocation], valuesPerMinute: [Double], sensorBasements: [Double], title: String) {
        self.closeButton.setTitle(title, forState: .Normal)

        if self.timelineLineChartView != nil {
            self.timelineLineChartView!.removeFromSuperview()
            self.timelineLineChartView = nil
        }
        if passes.count < 2 { return }

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        self.startTimeLabel.text = dateFormatter.stringFromDate(passes.first!.timestamp)
        self.endTimeLabel.text = dateFormatter.stringFromDate(passes.last!.timestamp)

        // max value
        var maxValue = 0.001
        var values: [NSNumber] = []
        for var i = 0; i < valuesPerMinute.count; i++ {
            let value = valuesPerMinute[i]
            if value > maxValue { maxValue = value }
        }
        // values
        if maxValue < sensorBasements.last! { maxValue = sensorBasements.last! }
        for var i = 0; i < valuesPerMinute.count; i++ {
            let value = valuesPerMinute[i] / maxValue * 100.0
            values.append(NSNumber(double: value))
        }

        // color view
        var topY = CGFloat(0.0)
        var bottomY = self.timelineLineChartBackgroundView.frame.height
        let colorViews = [self.greenView, self.yellowView, self.redView,]
        for var i = 0; i < colorViews.count; i++ {
            if i >= sensorBasements.count || sensorBasements[i] > maxValue { topY = CGFloat(0.0) }
            else { topY = self.timelineLineChartBackgroundView.frame.height * CGFloat(1.0 - sensorBasements[i] / maxValue) }
            colorViews[i].frame = CGRectMake(
                colorViews[i].frame.origin.x, topY,
                colorViews[i].frame.width, bottomY - topY
            )
            bottomY = topY
        }

        // line chart
        self.timelineLineChartView = JTChartView(
            frame: CGRectMake(0, 0, self.timelineLineChartBackgroundView.frame.width, self.timelineLineChartBackgroundView.frame.height),
            values: values,
            curveColor: UIColor.darkGrayColor(),
            curveWidth: 2.0,
            topGradientColor: UIColor.clearColor(),
            bottomGradientColor: UIColor.clearColor(),
            minY: 0.0,
            maxY: 1.0,
            topPadding: 0
        )
        self.timelineLineChartBackgroundView.addSubview(self.timelineLineChartView!)
/*
        self.timelineLineChartView.frame = CGRectMake(
            self.timeSlider.frame.origin.x, self.timelineLineChartView.frame.origin.y,
            self.timeSlider.frame.width, self.timelineLineChartView.frame.height
        )

        self.timelineLineChartView.clearChartData()
        if passes.count == 0 { return }

        self.timelineLineChartView.margin = 0
        self.timelineLineChartView.verticalGridStep = 1
        self.timelineLineChartView.horizontalGridStep = 1
        self.timelineLineChartView.labelForIndex = { (item) in
            //return dateFormatter.stringFromDate(timestamp.air_minutesAgo(minutes: -Int(item))!)
            return ""
        }
        self.timelineLineChartView.labelForValue = { (value) in
            //return "\(value)"
            return ""
        }
        self.timelineLineChartView.lineWidth = 2
        self.timelineLineChartView.color = color
        self.timelineLineChartView.fillColor = UIColor.clearColor()

        var allValuesAreNotZero = false
        for value in valuesPerMinute {
            allValuesAreNotZero = (allValuesAreNotZero || value > 0.0)
            if allValuesAreNotZero { break }
        }
        if allValuesAreNotZero {
            self.timelineLineChartView.setChartData(valuesPerMinute)
        }
*/
    }


    /// MARK: - private api

    /**
     * set up
     **/
    private func setUp() {
        self.dateView.layer.shadowOffset = CGSizeMake(0, 0)
        self.dateView.layer.shadowOpacity = 0.1

        self.timeSliderTitleView.layer.cornerRadius = 18.0
        self.timeSliderTitleView.layer.masksToBounds = true
        self.timeSliderTitleView.clipsToBounds = true
        self.timeSliderView.layer.shadowOffset = CGSizeMake(0, 0)
        self.timeSliderView.layer.shadowOpacity = 0.3
        self.timeSliderView.layer.shadowRadius = 2.0
        self.timeSliderView.layer.shadowPath = UIBezierPath(
            roundedRect: CGRectMake(self.timeSliderView.bounds.origin.x, self.timeSliderView.bounds.origin.y, UIScreen.mainScreen().bounds.width, self.timeSliderView.bounds.height),
            cornerRadius: 18.0
        ).CGPath

        self.closeButton.setImage(
            IonIcons.imageWithIcon(
                ion_chevron_up,
                iconColor: UIColor.darkGrayColor(),
                iconSize: 32, imageSize: CGSizeMake(32, 32)
            ),
            forState: .Normal
        )
        self.closeButton.setImage(
            IonIcons.imageWithIcon(
                ion_chevron_up,
                iconColor: UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0),
                iconSize: 32, imageSize: CGSizeMake(32, 32)
            ),
            forState: .Highlighted
        )

        self.setDate(NSDate())
    }

    /**
     * set date
     * @param date NSDate
     **/
    private func setDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        // year
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.stringFromDate(date)
        // month
        dateFormatter.dateFormat = "MMMM"
        let month = (dateFormatter.stringFromDate(date) as NSString).substringWithRange(NSRange(location: 0, length: 3))
        // day
        dateFormatter.dateFormat = " dd "
        let day = dateFormatter.stringFromDate(date)

        let yearString = NSAttributedString(
            string: year,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!,
                NSForegroundColorAttributeName: UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
            ]
        )
        let monthString = NSAttributedString(
            string: month,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 12)!,
                NSForegroundColorAttributeName: UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
            ]
        )
        let dayString = NSAttributedString(
            string: day,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 24)!,
                NSForegroundColorAttributeName: UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 64.0/255.0, alpha: 1.0)
            ]
        )
        let attributedText = NSMutableAttributedString()
        attributedText.appendAttributedString(monthString)
        attributedText.appendAttributedString(dayString)
        attributedText.appendAttributedString(yearString)
        self.dateButton.setAttributedTitle(attributedText, forState: .Normal)
    }

}

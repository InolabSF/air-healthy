// MARK: - AIRTimelineViewDelegate
@objc protocol AIRTimelineViewDelegate {

    /**
     * called when button is touched up inside
     * @param timelineView AIRTimelineView
     * @param button UIButton
     */
    func touchedUpInside(timelineView timelineView: AIRTimelineView, button: UIButton)

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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var timeSliderParentView: UIView!
    @IBOutlet weak var timeSliderView: UIView!
    @IBOutlet weak var timelineLineChartView: FSLineChart!
    @IBOutlet weak var timeSlider: GradientSlider!
    @IBOutlet weak var closeButton: UIButton!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.closeButton.setImage(
            IonIcons.imageWithIcon(
                ion_chevron_up,
                iconColor: UIColor.darkGrayColor(),
                iconSize: 144, imageSize: CGSizeMake(144, 144)),
            forState: .Normal
        )
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchUpInside(button button: UIButton) {
        if self.delegate != nil {
            (self.delegate as! AIRTimelineViewDelegate).touchedUpInside(timelineView: self, button: button)
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
        self.timeSlider.thumbColor = color
    }


    /// MARK: - private api

    /**
     * set line chart
     * @param lineChart line chart
     * @param valuesPerMinute [CGFloat]
     * @param color UIColor
     **/
    func setLineChart(passes passes: [CLLocation], valuesPerMinute: [CGFloat], color: UIColor) {
        self.timelineLineChartView.frame = CGRectMake(
            self.timeSlider.frame.origin.x, self.timelineLineChartView.frame.origin.y,
            self.timeSlider.frame.width, self.timelineLineChartView.frame.height
        )

        self.timelineLineChartView.clearChartData()
        if passes.count == 0 { return }

        let timestamp = passes.first!.timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        self.timelineLineChartView.verticalGridStep = 1
        self.timelineLineChartView.horizontalGridStep = 1
        self.timelineLineChartView.labelForIndex = { (item) in
            return dateFormatter.stringFromDate(timestamp.air_minutesAgo(minutes: -Int(item))!)
        }
        self.timelineLineChartView.labelForValue = { (value) in
            //return "\(value)"
            return ""
        }
        self.timelineLineChartView.lineWidth = 2
        self.timelineLineChartView.color = color
        self.timelineLineChartView.fillColor = UIColor.clearColor()
        self.timelineLineChartView.setChartData(valuesPerMinute)
    }

}

import UIKit
import CoreLocation


/// MARK: - AIRViewController
class AIRViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButton: UIButton!

    var shouldAnimatePieChart = true
    var locations: [CLLocation] = []

    var cellClassNames: [String] {
        var names = [NSStringFromClass(AIRPieChartTableViewCell)]
        for var i = 0; i < locations.count; i++ {
            if i%2 == 0 { names.append(NSStringFromClass(AIRLocationTableViewCell)) }
            else { names.append(NSStringFromClass(AIRTripTableViewCell)) }
        }
        return names
    }


    /// MARK: - life cycle

    override func loadView() {
        super.loadView()

        // title
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.darkGrayColor(),
            NSFontAttributeName: UIFont(name: "AmericanTypewriter-Bold", size: 24)!
        ]

        // right bar button
        self.rightBarButton.setImage(
            IonIcons.imageWithIcon(
                ion_android_settings,
                iconColor: UIColor.grayColor(),
                iconSize: 22,
                imageSize: CGSizeMake(22, 22)),
            forState: .Normal
        )
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let indexPath = self.tableView.indexPathForSelectedRow
        if indexPath != nil { self.tableView.deselectRowAtIndexPath(indexPath!, animated: true) }

        let date = NSDate()

        var newLocations = AIRLocation.fetchStarts(date: date) + AIRLocation.fetchStops(date: date)
        newLocations.sortInPlace({ $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedAscending })
        // Is there any updates?
        let lastLocation = self.locations.last
        let newLastLocation = newLocations.last
        var doesUpdate = (self.locations.count != newLocations.count)
        doesUpdate = doesUpdate || (self.locations.count > 0 && newLocations.count > 0 && lastLocation!.timestamp.compare(newLastLocation!.timestamp) != .OrderedSame)
        if doesUpdate {
            self.shouldAnimatePieChart = true
            self.locations = newLocations
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == AIRNSStringFromClass(AIRGraphViewController)) {
            let graphViewController = segue.destinationViewController as! AIRGraphViewController
            graphViewController.passes = AIRLocation.fetch(date: NSDate())
        }
        if (segue.identifier == AIRNSStringFromClass(AIRMapViewController)) {
            let date = NSDate()
            let mapViewController = segue.destinationViewController as! AIRMapViewController
            mapViewController.passes = AIRLocation.fetch(date: date)
            mapViewController.stops = AIRLocation.fetchStops(date: date)
        }
    }


    /// MARK: - event listener

    /**
     * called when button is touched up inside
     * @param button UIButton
     **/
    @IBAction func touchedUpInside(button button: UIButton) {
        if button == self.rightBarButton {
        }
    }

}


/// MARK: - UITableViewDelegate, UITableViewDataSource
extension AIRViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellClassNames.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let name = AIRNSStringFromClassString(self.cellClassNames[indexPath.row])
        let cell = UINib(nibName: name, bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AIRTableViewCell

        // design cell
        if name == AIRNSStringFromClass(AIRPieChartTableViewCell) {
            let airHealth = AIRSensorManager.healthEvaluation(name: "SO2", date: NSDate())
            (cell as! AIRPieChartTableViewCell).set(day: "Today", airHealth: airHealth, animated: self.shouldAnimatePieChart)
            self.shouldAnimatePieChart = false
        }
        else if name == AIRNSStringFromClass(AIRLocationTableViewCell) {
            (cell as! AIRLocationTableViewCell).set(location: self.locations[indexPath.row-1])
        }
        else if name == AIRNSStringFromClass(AIRTripTableViewCell) {
            (cell as! AIRTripTableViewCell).set(start: self.locations[indexPath.row-1], end: self.locations[indexPath.row])
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.cellClassNames.count <= 1 {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }

        let name = AIRNSStringFromClassString(self.cellClassNames[indexPath.row])

        // graph view controller
        if name == AIRNSStringFromClass(AIRPieChartTableViewCell) {
            self.performSegueWithIdentifier(AIRNSStringFromClass(AIRGraphViewController), sender: indexPath)
        }
        // map view controller
        else {
            self.performSegueWithIdentifier(AIRNSStringFromClass(AIRMapViewController), sender: indexPath)
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellClass = NSClassFromString(self.cellClassNames[indexPath.row]) as! AIRTableViewCell.Type
        return cellClass.air_height()
    }

}

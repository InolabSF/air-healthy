import UIKit
import CoreLocation


/// MARK: - AIRViewController
class AIRViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButton: UIButton!

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
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let indexPath = self.tableView.indexPathForSelectedRow
        if indexPath != nil { self.tableView.deselectRowAtIndexPath(indexPath!, animated: true) }

        let dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.year = 2015
        dateComponents.month = 11
        dateComponents.day = 10
        let date = calendar.dateFromComponents(dateComponents)

        var newLocations = AIRLocation.fetchStarts(date: date!) + AIRLocation.fetchStops(date: date!)
        newLocations.sortInPlace({ $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedAscending })
        // Is there any updates?
        let lastLocation = self.locations.last
        let newLastLocation = newLocations.last
        var doesUpdate = (self.locations.count != newLocations.count)
        doesUpdate = doesUpdate || (self.locations.count > 0 && newLocations.count > 0 && lastLocation!.timestamp.compare(newLastLocation!.timestamp) != .OrderedSame)
        if doesUpdate {
            self.locations = newLocations
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == AIRNSStringFromClass(AIRGraphViewController)) {
            //let graphViewController = segue.destinationViewController as! AIRGraphViewController
        }
        if (segue.identifier == AIRNSStringFromClass(AIRMapViewController)) {
            let mapViewController = segue.destinationViewController as! AIRMapViewController

            let dateComponents = NSDateComponents()
            let calendar = NSCalendar.currentCalendar()
            dateComponents.year = 2015
            dateComponents.month = 11
            dateComponents.day = 10
            let date = calendar.dateFromComponents(dateComponents)

            mapViewController.passes = AIRLocation.fetch(date: date!)
            mapViewController.stops = AIRLocation.fetchStops(date: date!)
        }
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(button button: UIButton) {
        if button == self.rightBarButton {
            let title = self.rightBarButton.titleForState(.Normal)
            let startTitle = "Start"
            let stopTitle = "Stop"

            if title == startTitle {
                self.rightBarButton.setTitle(stopTitle, forState: .Normal)
                AIRLocationManager.sharedInstance.startUpdatingLocation()
            }
            else if title == stopTitle {
                self.rightBarButton.setTitle(startTitle, forState: .Normal)
                AIRLocationManager.sharedInstance.stopUpdatingLocation()
                self.performSegueWithIdentifier(AIRNSStringFromClass(AIRMapViewController), sender: nil)
            }
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
            (cell as! AIRPieChartTableViewCell).set(airHealth: 65.0)
        }
        else if name == AIRNSStringFromClass(AIRLocationTableViewCell) {
        }
        else if name == AIRNSStringFromClass(AIRTripTableViewCell) {
            (cell as! AIRTripTableViewCell).set(start: self.locations[indexPath.row-2], end: self.locations[indexPath.row-1])
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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

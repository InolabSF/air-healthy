import UIKit


/// MARK: - AIRViewController
class AIRViewController: UIViewController {

    /// MARK: - property

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButton: UIButton!

    let sensors = ["NO2", "SO2", "03"]
    let graphs: [[CGFloat]] = [
        [1.0, 0.5, 2.0, 4.0, 3.0, 0.5],
        [3.5, 1.0, 4.0, 0.2, 0.5, 5.0],
        [2.0, 1.5, 1.0, 4.0, 1.0, 1.5]
    ]


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let indexPath = self.tableView.indexPathForSelectedRow
        if indexPath != nil { self.tableView.deselectRowAtIndexPath(indexPath!, animated: true) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == AIRNSStringFromClass(AIRGraphViewController)) {
            let graphViewController = segue.destinationViewController as! AIRGraphViewController
            graphViewController.title = sensors[(sender as! NSIndexPath).row]
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
        return sensors.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UINib(nibName: AIRNSStringFromClass(AIRLineGraphTableViewCell), bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AIRLineGraphTableViewCell
        cell.set(
            title: sensors[indexPath.row],
            graphDatas: graphs[indexPath.row]
        )

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(AIRNSStringFromClass(AIRGraphViewController), sender: indexPath)
    }

}

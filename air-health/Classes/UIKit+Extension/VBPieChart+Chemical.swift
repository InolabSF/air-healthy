/// MARK: - VBPieChart+Chemical
extension VBPieChart {

    /// MARK: - public api

    /**
     * set datas
     * @param chemical String
     * @param airHealth [Double]
     * @param animated Bool
     **/
    func setPieChart(airHealth airHealth: [Double], animated: Bool) {
        // pie chart
        self.enableStrokeColor = true
        self.holeRadiusPrecent = 0.5
        self.labelsPosition = VBLabelsPosition.OnChart
        self.startAngle = Float(M_PI / 2.0 * 3.0)

        let values = [
            [ // healthy
                "name" : "",
                "value" : NSNumber(double: airHealth[0]),
                "color" : UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
            ],
            [ // warning
                "name" : "",
                "value" : NSNumber(double: airHealth[1]),
                "color" : UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
            ],
            [ // unhealthy
                "name" : "",
                "value" : NSNumber(double: airHealth[2]),
                "color" : UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
            ],
        ]
        self.setChartValues(
            values,
            animation: animated,
            duration: 0.8,
            options: [.FanAll, .TimingEaseIn]
        )
    }

}

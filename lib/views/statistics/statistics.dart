import 'package:fl_chart/fl_chart.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';
import 'package:odrive_restaurant/common/const/const.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int totalOrders = 0;
  double totalEarnings = 0.0;
  List<BarChartGroupData> earningsData = [];
  List<FlSpot> ordersData = [];
  late Map<String, int> ordersByDate = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await getStatistics();

    if (response["error"] == "0") {
      final List<dynamic> earningsList = response['data'];

      setState(() {
        totalOrders = earningsList.length;
        totalEarnings = earningsList.fold(
            0.0, (sum, item) => sum + double.parse(item['total']));

        for (var item in earningsList) {
          String date = item['updated_at'].split(' ')[0];
          ordersByDate.update(date, (value) => value + 1, ifAbsent: () => 1);
        }

        earningsData = earningsList.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return BarChartGroupData(
            x: index + 1,
            barRods: [
              BarChartRodData(
                fromY: 0,
                toY: double.parse(item['total']),
                width: 15,
                color: appColor,
              ),
            ],
          );
        }).toList();

        ordersData = earningsList.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return FlSpot((index + 1).toDouble(), double.parse(item['total']));
        }).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BgContainer(),
          const CustomAppBar(
            leadingImageAsset: drawer,
            title: 'Statistics',
            notificationImageAsset: notificationIcon,
          ),
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 20.0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 84,
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(5, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  'Total Orders'
                                      .text
                                      .color(fontGrey)
                                      .size(16)
                                      .semiBold
                                      .make(),
                                  '$totalOrders'
                                      .text
                                      .color(blackColor)
                                      .semiBold
                                      .size(18)
                                      .make(),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  'Total Earnings'
                                      .text
                                      .color(fontGrey)
                                      .size(16)
                                      .semiBold
                                      .make(),
                                  'F ${totalEarnings.round()}'
                                      .text
                                      .color(blackColor)
                                      .semiBold
                                      .size(18)
                                      .overflow(TextOverflow.ellipsis)
                                      .make(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        // height: MediaQuery.of(context).size.height * 0.5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: blue, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(5, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  'Earnings'
                                      .text
                                      .color(fontGrey)
                                      .bold
                                      .size(18)
                                      .make(),
                                  customButton(
                                      context: context,
                                      width: MediaQuery.of(context).size.width *
                                          0.33,
                                      height: 44,
                                      title: 'Last 10 days',
                                      onPress: () {})
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: AspectRatio(
                                aspectRatio: 1.4,
                                child: BarChart(
                                  BarChartData(
                                      borderData: FlBorderData(
                                        show: true,
                                        border: const Border(
                                          top: BorderSide(width: 1),
                                          right: BorderSide(width: 1),
                                          left: BorderSide(width: 1),
                                          bottom: BorderSide(width: 1),
                                        ),
                                      ),
                                      groupsSpace: 10,
                                      barGroups: earningsData),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      20.heightBox,
                      Container(
                        // height: MediaQuery.of(context).size.height * 0.36,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: blue, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(5, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  'Orders'
                                      .text
                                      .color(fontGrey)
                                      .bold
                                      .size(18)
                                      .make(),
                                  customButton(
                                      context: context,
                                      width: MediaQuery.of(context).size.width *
                                          0.33,
                                      height: 44,
                                      title: 'Last 10 days',
                                      onPress: () {})
                                ],
                              ),
                            ),
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: LineChart(LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: ordersByDate.entries.map((entry) {
                                        int index = ordersByDate.keys
                                            .toList()
                                            .indexOf(entry.key);
                                        return FlSpot(index.toDouble(),
                                            entry.value.toDouble());
                                      }).toList(),
                                      isCurved: true,
                                      dotData: const FlDotData(show: true),
                                      color: appColor,
                                      barWidth: 1,
                                      curveSmoothness:
                                          BorderSide.strokeAlignOutside,
                                      belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.transparent),
                                    )
                                  ],
                                  minX: 0,
                                  maxX: ordersByDate.length.toDouble() - 1,
                                  minY: 0,
                                  maxY: ordersByDate.isNotEmpty
                                      ? ordersByDate.values
                                              .reduce((a, b) => a > b ? a : b)
                                              .toDouble() +
                                          5
                                      : 5,
                                  backgroundColor: white,
                                  titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                          axisNameWidget: const Text('Date'),
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            interval: 1,
                                          )),
                                      leftTitles: const AxisTitles(
                                          axisNameWidget: Text('Total'),
                                          sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40))),
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    getDrawingHorizontalLine: (value) =>
                                        const FlLine(
                                            color: appColor, strokeWidth: 0.5),
                                    drawVerticalLine: true,
                                    getDrawingVerticalLine: (value) =>
                                        const FlLine(
                                            color: blackColor,
                                            strokeWidth: 0.5),
                                  ),
                                  borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                          color: fontGrey, width: 1)))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

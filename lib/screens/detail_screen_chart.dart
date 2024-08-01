import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final String schemeCode;

  DetailScreen({required this.schemeCode});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Map<String, dynamic>> futureData;
  List<ChartData> priceDataPoints = [];
  DateTime? startDate;
  DateTime? endDate;
  Map<String, dynamic>? metaData;

  @override
  void initState() {
    super.initState();
    futureData = fetchMutualFundData(widget.schemeCode);
  }

  Future<Map<String, dynamic>> fetchMutualFundData(String schemeCode) async {
    final response = await http.get(Uri.parse('https://api.mfapi.in/mf/$schemeCode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        metaData = data['meta'];
      });
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void processPriceData(Map<String, dynamic> data) {
    priceDataPoints.clear();
    final formatter = DateFormat('dd-MM-yyyy');

    for (var priceItem in data['data']) {
      final dateString = priceItem['date'];
      final parsedDate = formatter.parse(dateString);

      if (startDate != null && endDate != null) {
        if (parsedDate.isAfter(startDate!.subtract(Duration(days: 1))) && parsedDate.isBefore(endDate!.add(Duration(days: 1)))) {
          priceDataPoints.add(ChartData(
            x: parsedDate,
            y: double.parse(priceItem['nav']),
          ));
        }
      } else {
        priceDataPoints.add(ChartData(
          x: parsedDate,
          y: double.parse(priceItem['nav']),
        ));
      }
    }
  }

  Future<void> _showDateRangePicker() async {
    final selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDateRange != null) {
      setState(() {
        startDate = selectedDateRange.start;
        endDate = selectedDateRange.end;
      });
      final data = await fetchMutualFundData(widget.schemeCode);
      processPriceData(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Detail Screen'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;

            if (metaData == null) {
              metaData = data['meta'];
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Mutual Fund Details',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INFORMATION OF FUND',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          // Text('Fund House: ${metaData?['fund_house'] ?? ''}'),
                          // Text('Scheme Type: ${metaData?['scheme_type'] ?? ''}'),
                          // Text('Scheme Category: ${metaData?['scheme_category'] ?? ''}'),
                          // Text('Scheme Code: ${metaData?['scheme_code'] ?? ''}'),
                          // Text('Scheme Name: ${metaData?['scheme_name'] ?? ''}'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Fund House : ',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: data['meta']['fund_house'] ?? '',
                                        style: TextStyle(color: Colors.black),
                                      )
                                    ]
                                  )
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Scheme Type : ',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: data['meta']['scheme_type'] ?? '',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Scheme Category : ',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: data['meta']['scheme_category'] ?? '',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Scheme Code : ',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: data['meta']['scheme_code']?.toString() ?? '',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Scheme Name : ',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: data['meta']['scheme_name'] ?? '',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Price Chart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showDateRangePicker,
                    child: Text('Select Date Range', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        dateFormat: DateFormat('dd-MM-yy'),
                        intervalType: DateTimeIntervalType.days,
                      ),
                      primaryYAxis: NumericAxis(
                        labelFormat: '{value}',
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      series: <CartesianSeries>[
                        LineSeries<ChartData, DateTime>(
                          dataSource: priceDataPoints,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: Colors.blue,
                          width: 2,
                          markerSettings: MarkerSettings(isVisible: true),
                        ),
                      ],
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ChartData {
  ChartData({required this.x, required this.y});

  final DateTime x;
  final double y;
}

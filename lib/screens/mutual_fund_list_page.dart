import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../servicces/mutual_fund_service.dart';
import 'detail_screen_chart.dart';

class MutualFundsListPage extends StatefulWidget {
  @override
  _MutualFundsListPageState createState() => _MutualFundsListPageState();
}

class _MutualFundsListPageState extends State<MutualFundsListPage> {
  late Future<List<MutualFund>> futureMutualFunds;
  List<MutualFund> allMutualFunds = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureMutualFunds = fetchMutualFunds();
  }

  void filterList(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mutual Funds'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(244, 243, 243, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              onChanged: filterList,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black87,
                ),
                hintText: "Search by Scheme Name",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MutualFund>>(
              future: futureMutualFunds,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(10),
                        child: Shimmer.fromColors(
                          period: Duration(seconds: 5),
                          baseColor: Colors.white24,
                          highlightColor: Colors.black12!,
                          child: Card(
                            color: Colors.black,
                            child: ListTile(
                              title: Container(
                                color: Colors.grey,
                                height: 20,
                              ),
                              subtitle: Container(
                                color: Colors.grey,
                                height: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  final allMutualFunds = snapshot.data!;
                  final filteredMutualFunds = allMutualFunds.where((fund) =>
                      fund.schemeName.toLowerCase().contains(searchQuery.toLowerCase())
                  ).toList();

                  return ListView.builder(
                    itemCount: filteredMutualFunds.length,
                    itemBuilder: (context, index) {
                      final fund = filteredMutualFunds[index];

                      return GestureDetector(
                        onTap: () {
                          print('Scheme Code Passed: ${fund.schemeCode}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(schemeCode: fund.schemeCode),

                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: Stack(
                            children: [
                              Card(
                                color: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(style: BorderStyle.solid, width: 2, color: Colors.green),
                                ),
                                elevation: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Icon(Icons.book, color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              fund.schemeName.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Scheme Code: ${fund.schemeCode}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';

class MutualFund {
  final String schemeCode;
  final String schemeName;

  MutualFund({required this.schemeCode, required this.schemeName});

  factory MutualFund.fromJson(Map<String, dynamic> json) {
    return MutualFund(
      schemeCode: json['schemeCode'].toString(),
      schemeName: json['schemeName'],
    );
  }
}

class MutualFundDetail {
  final String schemeName;
  final String fundHouse;
  final String schemeType;
  final String schemeCategory;
  final String schemeCode;
  final List<PriceData> priceData;

  MutualFundDetail({
    required this.schemeName,
    required this.fundHouse,
    required this.schemeType,
    required this.schemeCategory,
    required this.schemeCode,
    required this.priceData,
  });

  factory MutualFundDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> priceList = json['price_data'];
    final List<PriceData> prices = priceList.map((item) => PriceData.fromJson(item)).toList();

    return MutualFundDetail(
      schemeName: json['scheme_name'],
      fundHouse: json['fund_house'],
      schemeType: json['scheme_type'],
      schemeCategory: json['scheme_category'],
      schemeCode: json['scheme_code'],
      priceData: prices,
    );
  }
}

class PriceData {
  final double date;
  final double nav;

  PriceData({
    required this.date,
    required this.nav,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      date: json['date'].toDouble(),
      nav: json['nav'].toDouble(),
    );
  }
}

Future<List<MutualFund>> fetchMutualFunds() async {
  final response = await http.get(Uri.parse('https://api.example/mf'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => MutualFund.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load mutual funds data');
  }
}

Future<MutualFundDetail> fetchMutualFundDetail(String schemeCode) async {
  final response = await http.get(Uri.parse('https://api.example/mf/$schemeCode'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return MutualFundDetail.fromJson(data);
  } else {
    throw Exception('Failed to load mutual fund detail');
  }
}

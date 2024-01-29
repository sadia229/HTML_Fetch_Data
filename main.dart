import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> tableData = [];
  String url = 'https://10minuteschool.com/content/10th-bcs-preli-question-bank/?ref=https%3A%2F%2F10minuteschool.com%2Fcontent%2Fcategory%2Fbcs-and-bank-jobs%2Fbcs-question-bank%2F%3Futm_source%3Dgoogle%26utm_medium%3Dcpc%26utm_campaign%3Dna_branddefence_search_rsa_maxconversions%28tcpa%29_conversion%26utm_content%3Dtxt_na_na%26utm_term%3D1p_detailed_demo%2Binmkt%2Baff_all_18-54_dynamic_new%26campaign%3Dgoogle-ads%26type%3Dsearch%26gad_source%3D1%26gclid%3DCjwKCAiAk9itBhASEiwA1my_6x5OXAEr8tc-HLE3xBgaUHHiPArZHSi1Q_E0pZW7OGMVTUc77G0dZBoCuoUQAvD_BwE&post_id=10017&blog_category_id=3639';


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if data is cached
    final cachedData = prefs.getString('cachedData');
    if (cachedData != null) {
      // Use cached data if available
      setState(() {
        tableData = cachedData.split('\n');
      });
    } else {
      // Fetch data from the network
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final htmlDocument = htmlParser.parse(response.body);

        // Extract table rows from the body
        final bodyElement = htmlDocument.querySelector('body');
        final tableRows = bodyElement?.querySelectorAll('tr');

        if (tableRows != null) {
          for (final row in tableRows) {
            final rowData = row.text;
            tableData.add(rowData);
          }

          // Cache the data
          prefs.setString('cachedData', tableData.join('\n'));

          setState(() {});
        }
      } else {
        throw Exception('Failed to load HTML data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caching Example'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final rowData in tableData) Text(rowData),
            ],
          ),
        ),
      ),
    );
  }
}

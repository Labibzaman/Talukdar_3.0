import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Data App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController buyerController = TextEditingController();
  TextEditingController sellerController = TextEditingController();
  TextEditingController trackController = TextEditingController();
  TextEditingController materialController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController grossController = TextEditingController();
  TextEditingController tareController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  List<Map<String, dynamic>> savedData = [];


  @override
  void initState() {
    super.initState();
    // Load data when the app starts
    loadData();
  }

  void saveData() {
    int invoiceNumber = Random().nextInt(100000);

    if (buyerController.text.isEmpty ||
        trackController.text.isEmpty ||
        quantityController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Data'),
            content: Text('Please enter data in all required fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    double totalAmountValue = double.parse(quantityController.text) *
        double.parse(priceController.text);

    double netWeightValue =
        double.parse(grossController.text) - double.parse(tareController.text);

    Map<String, dynamic> newDataEntry = {
      'Invoice Number': invoiceNumber, // Include invoice number
      'Buyer Name': buyerController.text,
      'Seller Name': sellerController.text,
      'Track Name': trackController.text,
      'Material Name': materialController.text,
      'Quantity': quantityController.text,
      'Gross (1st weight)': grossController.text,
      'Tare (2nd weight)': tareController.text,
      'Price': priceController.text,
      'Net Weight': netWeightValue,
      'Total Amount': totalAmountValue,
    };

    saveDataToSharedPreferences(newDataEntry);

    clearTextFields();
  }

  Future<void> saveDataToSharedPreferences(
      Map<String, dynamic> newDataEntry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('user_data') ?? [];

    String newDataEntryString = newDataEntry.toString();
    data.add(newDataEntryString);

    await prefs.setStringList('user_data', data);

    setState(() {
      savedData.add(newDataEntry);
    });
  }

  void clearTextFields() {
    buyerController.clear();
    sellerController.clear();
    trackController.clear();
    materialController.clear();
    quantityController.clear();
    grossController.clear();
    tareController.clear();
    priceController.clear();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList('user_data');

    if (data != null) {
      setState(() {
        savedData = data.map((entry) {
          Map<String, dynamic> dataMap = mapFromString(entry);
          return dataMap;
        }).toList();
      });
    }
  }

  Map<String, dynamic> mapFromString(String str) {
    Map<String, dynamic> dataMap = {};
    List<String> parts = str.split(', ');

    for (String part in parts) {
      var keyVal = part.split(': ');
      String key = keyVal[0];
      dynamic value = keyVal[1];
      dataMap[key] = value;
    }

    return dataMap;
  }

  void editData(int index) {
    Map<String, dynamic> selectedData = savedData[index];

    buyerController.text = selectedData['Buyer Name'];
    sellerController.text = selectedData['Seller Name'];
    trackController.text = selectedData['Track Name'];
    materialController.text = selectedData['Material Name'];
    quantityController.text = selectedData['Quantity'];
    grossController.text = selectedData['Gross (1st weight)'];
    tareController.text = selectedData['Tare (2nd weight)'];
    priceController.text = selectedData['Price'];

    int invoiceNumber = selectedData['Invoice Number'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: buyerController,
                  decoration: InputDecoration(labelText: 'Buyer Name'),
                ),
                TextField(
                  controller: sellerController,
                  decoration: InputDecoration(labelText: 'Seller Name'),
                ),
                TextField(
                  controller: trackController,
                  decoration: InputDecoration(labelText: 'Track Name'),
                ),
                TextField(
                  controller: materialController,
                  decoration: InputDecoration(labelText: 'Material Name'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextField(
                  controller: grossController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Gross (1st weight)'),
                ),
                TextField(
                  controller: tareController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Tare (2nd weight)'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),

                // Display the invoice number in the dialog
                Text('Invoice Number: $invoiceNumber'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                saveEditedData(index, invoiceNumber);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void saveEditedData(int index, int invoiceNumber) {
    if (buyerController.text.isEmpty ||
        trackController.text.isEmpty ||
        quantityController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Data'),
            content: Text('Please enter data in all required fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    double totalAmountValue = double.parse(quantityController.text) *
        double.parse(priceController.text);

    double netWeightValue =
        double.parse(grossController.text) - double.parse(tareController.text);

    Map<String, dynamic> editedData = {
      'Invoice Number': invoiceNumber, // Include invoice number
      'Buyer Name': buyerController.text,
      'Seller Name': sellerController.text,
      'Track Name': trackController.text,
      'Material Name': materialController.text,
      'Quantity': quantityController.text,
      'Gross (1st weight)': grossController.text,
      'Tare (2nd weight)': tareController.text,
      'Price': priceController.text,
      'Net Weight': netWeightValue,
      'Total Amount': totalAmountValue,
    };

    setState(() {
      savedData[index] = editedData;
    });

    clearTextFields();

    saveEditedDataToSharedPreferences();
  }

  void saveEditedDataToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = savedData.map((dataMap) => dataMap.toString()).toList();
    prefs.setStringList('user_data', data);
  }

  Future<void> deleteData(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  savedData.removeAt(index);
                });

                List<String> updatedData =
                savedData.map((dataMap) => dataMap.toString()).toList();
                prefs.setStringList('user_data', updatedData);

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size mq =  MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Talukdar Auto Rice Mill')),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 200,
                          child: TextField(
                            controller: trackController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Truck No'),
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          controller: sellerController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: 'Seller Name'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 200,
                          child: TextField(
                            controller: buyerController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Buyer Name'),
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          controller: materialController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: 'Material Name'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 200,
                          child: TextField(
                            controller: quantityController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Quantity'),
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          controller: grossController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: 'Gross (1st weight)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 200,
                          child: TextField(
                            controller: tareController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Tare (2nd weight)'),
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          controller: priceController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: 'Price'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            saveData();
                          },
                          child: Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  if (savedData.isNotEmpty)
                    SingleChildScrollView(
                      child: Container(

                        width: mq.width*0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                          savedData.asMap().entries.toList().reversed.map((entry) {
                            final index = entry.key;
                            final dataMap = entry.value;

                            // Convert the data map to a formatted string for display
                            String formattedData = dataMap.entries.map((entry) {
                              return '${entry.key}: ${entry.value}';
                            }).join(', ');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  child: ListTile(
                                    title: Text(formattedData),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        editData(index);
                                      },
                                      child: Text('Edit'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (savedData.isNotEmpty) {
                                          printPdf(savedData.first);
                                        }
                                      },
                                      child: Text('Print'),
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        deleteData(index);
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class Saveprint extends StatelessWidget {
  const Saveprint({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){

    }, child: Text('Save as pdf'));
  }
}

Future<Future<Uint8List>> generatepdf(Map<String, dynamic> data) async {
  final pdf = pw.Document();
  pdf.addPage(
      pw.Page(
      build: (pw.Context context) {
        return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
                children: <pw.Widget>[
          pw.Text('Invoice Number: ${data['Invoice Number']}'),
          pw.Text('Buyer Name: ${data['Buyer Name']}'),
              pw.Text('Seller Name: ${data['Seller Name']}'),
              pw.Text('Track Name: ${data['Track Name']}'),
              pw.Text('Material Name: ${data['Material Name']}'),
              pw.Text('Quantity: ${data['Quantity']}'),
              pw.Text('Gross 1stWeight: ${data['Gross 1stWeight']}'),
              pw.Text('Tare 2ndWeight: ${data['Tare 2nd weight']}'),
              pw.Text('Price: ${data['Price']}'),
              pw.Text('Net Weight: ${data['Net Weight']}'),
              pw.Text('Total Amount: ${data['Total Amount']}'),
        ]));
      }));
  return pdf.save();
}

Future<void> printPdf(Map<String, dynamic> data) async {
  final pdfData = await generatepdf(data);
  await Printing.layoutPdf(
    onLayout: (format) => pdfData,
  );
}

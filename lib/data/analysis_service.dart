import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/Analysis.dart';

class AnalysisService{
  static List<Analysis> all_analysis = [];

  static AnalysisService _singleton = new AnalysisService._internal();

  factory AnalysisService(){
    return _singleton;
  }
  AnalysisService._internal();

  static Future getAnalysis () async{
    final String response =
  await rootBundle.loadString('assets/54478355056.json');
  final _data =json.decode(response);
    return _data;
    // final _response = await http.get(Uri.parse("http://10.0.2.2:3000/tahliller"));
    // if (_response.statusCode == 200){
    //   return json.decode(_response.body);
    // }
    // else {
    //   throw Exception("Yükleme başarısız.");
    // }

  }

  static Future<List<Analysis>> extractText(String file_path) async {
    // final result = await FilePicker.platform.pickFiles();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    Uint8List? file_int;

    if (result != null) {
      PlatformFile file = result.files.first;
      file_int =  file.bytes;
      // print(file.name);
      // print(file.bytes);
      // print(file.size);
      // print(file.extension);
      // print(file.path);
      // Get the application document directory
//       Directory appDocDir = await getApplicationDocumentsDirectory();
// // Get the absolute path
//       String appDocPath = appDocDir.path;
// // Copy it to the new file
// //       final File fileForFirebase = File(pdf.path);
//       final File newFile = await file.copy('$appDocPath/your_file_name.${file.extension}');

    }


    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsBytes(file_int!);

    return get_all(file_int);


  }

  static Future<List<Analysis>> get_all(Uint8List file_int) async {
    int page_size = 0;
    PdfDocument document =
    PdfDocument(inputBytes:file_int);
    //  File(file_path).re await _readDocumentData(file_path)
    page_size = document.pages.count;
    PdfTextExtractor extractor = PdfTextExtractor(document);
    String text = "";
    List<Analysis> analysis_list = [];
    String tarih = "";
    String ust_sinif = "";
    for (int i = 0; i < page_size ; i++) {
      // if(i ==0){

      text = extractor.extractText(startPageIndex: i);
      List<String> analysis = text.split("\n");
      analysis.removeRange(0, 6);
      analysis.removeAt(analysis.length - 1);
      for (int j = 0; j < analysis.length - 1; j++) {
        List<String> first2 = [analysis[j], analysis[j + 1], analysis[j + 2]];

        if (first2[2].contains("-")) {
          analysis_list
              .add(Analysis(analysis[j + 1], "", "", "", analysis[j], ""));
          tarih = analysis[j];
          ust_sinif = analysis[j + 1];
          if (analysis[j + 1].contains("İdrar analizi (Strip ile)")) {
            break;
          }
          j = j + 1;
          continue;
        }
        if (first2[0].contains("-")) {
          analysis_list.add(Analysis(analysis[j + 1], analysis[j + 2],
              analysis[j + 3], analysis[j + 4], tarih, ust_sinif));
          j = j + 4;
          continue;
        } else {
          analysis_list.add(Analysis(analysis[j + 1], analysis[j + 2],
              analysis[j + 3], analysis[j + 4], analysis[j], ""));
          j = j + 4;

          continue;
        }
      }

    }
    // dispose
    document.dispose();
    return analysis_list;
  }







}


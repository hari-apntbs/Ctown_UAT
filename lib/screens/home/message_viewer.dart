import 'dart:io';


import 'package:ctown/screens/home/message_image_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import "package:path_provider/path_provider.dart";
import 'package:url_launcher/url_launcher.dart';

class MessageViewer extends StatefulWidget {
  final title;
  final body;
  final message_content;
  final message_files;
  final id;
  final String? url;
  const MessageViewer(
      {Key? key,
      this.message_files,
      this.id,
      this.message_content,
      this.title,
      this.body,
      this.url})
      : super(key: key);

  @override
  _MessageViewerState createState() => _MessageViewerState();
}

class _MessageViewerState extends State<MessageViewer> {
  _launchURL(_url) async {
    String url = _url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<File> viewFile({required String url, String? fileName, String? dir}) async {
    HttpClient httpClient = HttpClient();
    File file;
    var request = await httpClient.getUrl(Uri.parse(url));
    print(request);
    var response = await request.close();
    print(response);
    print(response.statusCode);
    var bytes;
    if (response.statusCode == 200) {
      bytes = await consolidateHttpClientResponseBytes(response);
      final output = await getTemporaryDirectory();
      print("output");
      final file = File("${output.path}/$fileName.pdf");
      print("file write starts");
      var invoice = await file.writeAsBytes(bytes);
      print("file write ends");
      return invoice;
    } else {
      return Future.error('error');
    }
    // return file;
  }

  @override
  void initState() {
    print(widget.url);
    print("urllllll");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).colorScheme.surface),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  widget.body,
                  style: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.normal),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(widget.message_content),
            ),
            if (widget.message_files.toString().contains('.png') ||
                widget.message_files.toString().contains('.jpg'))
              Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                     
                      height: 80,
                      width: 80,
                      child: Image.network(widget.message_files)),
                  Container(
                     padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          "View",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImageView(
                                        image: widget.message_files,
                                      )));
                        }),
                  )
                ],
              ),
            if (widget.message_files.toString().contains('.pdf'))
              ListTile(
                tileColor: Colors.grey,
                leading: Icon(Icons.picture_as_pdf),
                title: Text(
                  "${widget.id}.pdf",
                ),
                trailing: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12))),
                        context: context,
                        builder: (context) {
                          return FutureBuilder(
                              future: viewFile(
                                  url: widget.message_files,
                                  fileName: "Invoice_${widget.id}",
                                  dir: "/storage/emulated/0/Download"),
                              builder: (context, AsyncSnapshot snapshot) {
                                // if (snapshot
                                //     .hasError) {
                                //   return Container(
                                //       height: MediaQuery.of(context).size.height * 0.9,
                                //       child: Center(child: Text('Could not generate invoice at this time')));
                                // }
                                if (snapshot.data == null) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40)),
                                  child: PdfPreview(
                                    build: (format) =>
                                        snapshot.data.readAsBytes(),
                                  ),
                                );
                              });
                        },
                      );
                    },
                    child: Icon(Icons.download_sharp)),
              ),
            SizedBox(
              height: 10,
            ),
            widget.url!.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        child: const Text(
                          "URL LINK:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            _launchURL(widget.url);
                          },
                          child: Text(
                            widget.url!,
                            style: TextStyle(
                                // fontSize: 20,
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          )),
                    ],
                  )
                : Container()
          ],
        ),
      ),
      // child: Container(child:Image.network(widget.message_files))),
    );
  }
}

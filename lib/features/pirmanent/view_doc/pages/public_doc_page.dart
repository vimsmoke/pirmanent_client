import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pirmanent_client/constants.dart';
import 'package:pirmanent_client/main.dart';
import 'package:pirmanent_client/models/document_model.dart';
import 'package:http/http.dart' as http;
import 'package:pirmanent_client/models/user_model.dart';
import 'package:pirmanent_client/utils.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../widgets/document_tile.dart';

class PublicDocsPage extends StatefulWidget {
  const PublicDocsPage({super.key});

  @override
  State<PublicDocsPage> createState() => _PublicDocsPageState();
}

class _PublicDocsPageState extends State<PublicDocsPage> {
  TextEditingController searchDocController = TextEditingController();

  int getCrossAxisCount() {
    var sWidth = MediaQuery.of(context).size.width;

    return sWidth > 1400
        ? 5
        : sWidth > 1200
            ? 4
            : sWidth > 928
                ? 3
                : 2;
  }

  List<Document> pubDocs = [];

  void getPubDocs() async {
    final pbUrl = await getPbUrl();

    final pb = PocketBase(pbUrl);

    final documentsResponse = await http.get(
        Uri.parse(
            "$pbUrl/api/collections/documents/records?filter=isPublic=true"),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-type': 'application/json',
        });

    if (documentsResponse.statusCode == 200) {
      final data = jsonDecode(documentsResponse.body);

      // Check if the response contains a list under a specific key
      final items = data['items'] ?? data;

      // Ensure items is a list
      if (items is List) {
        for (var item in items) {
          // get uploader data
          final uploader =
              await pb.collection('users').getOne(item['uploader'], expand: "");
          // get signer data
          final signer = await pb.collection('users').getOne(item['signer']);
          print(item['isVerified']);
          print("doc description: ${item['isVerified']}");

          pubDocs.add(Document(
            docId: item['id'],
            title: item['title'],
            uploader: User(
              email: uploader.data['email'],
              name: uploader.data['name'],
              publicKey: uploader.data['publicKey'],
            ),
            dateUploaded: DateTime.parse(item['created']),
            description: item['description'],
            signer: User(
              email: signer.data['email'],
              name: signer.data['name'],
              publicKey: signer.data['publicKey'],
            ),
            status: item['status'] == 'waiting'
                ? DocumentStatus.waiting
                : item['status'] == 'signed'
                    ? DocumentStatus.signed
                    : DocumentStatus.cancelled,
            uploadedDigitalSignature: item['uploadedDigitalSignature'],
            dateSigned: item['dateSigned'] == ""
                ? null
                : DateTime.parse(item['dateSigned']),
            signedDigitalSignature: item['signedDigitalSignature'] == ""
                ? null
                : item['signedDigitalSignature'],
            isVerified: item['isVerified'] == false ? false : true,
          ));
        }

        setState(() {
          pubDocs;
        });
      } else {
        print('Expected a list but got: ${items.runtimeType}');
      }
    } else {
      print('Failed to fetch collection data: ${documentsResponse.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();

    getPubDocs();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 200,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // headline
            Text(
              "Public Documents",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kHeadline,
              ),
            ),

            const SizedBox(height: 16),

            // public documents list
            Expanded(
              child: pubDocs.isEmpty
                  ? Center(
                      child: Text(
                        "No public documents",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: kSubheadline,
                        ),
                      ),
                    )
                  : GridView.builder(
                      itemCount: pubDocs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        crossAxisCount: getCrossAxisCount(),
                      ),
                      itemBuilder: (context, index) {
                        return DocumentTile(
                          doc: pubDocs[index],
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

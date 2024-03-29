// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/image_picker.dart';
import '../../../../data/models/account_model.dart';
import '../../../../data/models/post_models.dart';
import '../../../accounts/account_info_controller.dart';
import '../../home/home.dart';

class PublishTopic extends StatefulWidget {
  const PublishTopic(
      {super.key,
      required this.name,
      required this.id,
      required this.content,
      required this.contentType});

  final String name;
  final String id;
  final String content;
  final String contentType;

  @override
  State<PublishTopic> createState() => _PublishTopicState();
}

class _PublishTopicState extends State<PublishTopic> {
  String? owner = FirebaseAuth.instance.currentUser!.email;
  final accuntInfo = Get.put(AccountInfoController());

  final validationKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String imgUrl = "null";
  String? title;
  String? description;

  Widget imagePlacholder = const SizedBox(
    child: Center(
      child: Icon(Icons.add_photo_alternate_outlined),
    ),
  );
  Widget loadingIconOnUploadIMage = const SizedBox(
    child: Text("Choice an Image"),
  );
  Widget loadingIconOnPublishTopics = const SizedBox(
    child: Text("Publish"),
  );

  void publish() async {
    if (validationKey.currentState!.validate()) {
      setState(() {
        loadingIconOnPublishTopics = SizedBox(
          child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white, size: 40),
        );
      });
      final count =
          await FirebaseDatabase.instance.ref("/contents/count/").get();
      int id = 0;
      if (count.value != null) {
        id = int.parse(count.value.toString());
      }

      final classContentRef = FirebaseDatabase.instance.ref("classContent");
      int classContentCount = 0;
      var classContentCountData =
          await classContentRef.child('contentCount').get();
      if (classContentCountData.value != null) {
        classContentCount = int.parse(classContentCountData.value.toString());
      }
      await FirebaseDatabase.instance
          .ref("classContent/$classContentCount")
          .set(widget.content);
      await FirebaseDatabase.instance
          .ref("classContent/contentCount")
          .set("${classContentCount + 1}");

      String contentPath = "classContent/$classContentCount";

      PostModel post = PostModel(
        profile: accuntInfo.img.value,
        id: "$id",
        ownerUid: FirebaseAuth.instance.currentUser!.uid,
        contentType: widget.contentType,
        topic: widget.name,
        topicId: widget.id,
        title: titleController.text,
        img: imgUrl,
        owner: owner!,
        ownerName: accuntInfo.name.value,
        description: descriptionController.text,
        content: contentPath,
        likes: {
          "id": Like(uid: "null", date: "date"),
        },
        comments: {
          "id": Comment(
            profile: "null",
            email: "null",
            date: "null",
            uid: "null",
            message: "null",
          ),
        },
        share: "0",
        impression: "0",
      );

      int classCount = 0;
      var classCountData =
          await FirebaseDatabase.instance.ref("/contents/$id/classCount").get();

      if (classCountData.exists) {
        classCount = int.parse(classCountData.value.toString());
      }

      Map<String, dynamic> postDataMap = post.toMap();
      var ref = FirebaseDatabase.instance.ref("/contents/$id/$classCount");

      await ref.set(postDataMap);
      ref = FirebaseDatabase.instance.ref("/contents/$id/classCount");
      ref.set(
        "${(classCount + 1)}",
      );

      // update user Data
      final user = FirebaseAuth.instance.currentUser!;
      final userRef = FirebaseDatabase.instance.ref('user/${user.uid}/');
      final data = await userRef.get();

      final userData = jsonDecode(jsonEncode(data.value));

      AccountModel accountModel = AccountModel(
        userName: userData['userName'],
        userEmail: userData['userEmail'],
        uid: userData["uid"],
        img: userData['img'],
        allowMessages: userData['allowMessages'],
        posts: userData['posts'] ?? [],
        followers: userData['followers'] ?? [],
      );
      accountModel.posts.add("/contents/$id/$classCount");
      await userRef.update(accountModel.toJson());
      showModalBottomSheet(
        context: context,
        builder: (context) => const Center(
          child: SizedBox(
            child: Text("Uploaded"),
          ),
        ),
      );

      Get.off(() => const HomePage());

      showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Successfully Uploaded'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "We need some infomation about this post. Proper and detailed infromation will help your post to get by search easily. We also recommand to upload a photo that is releted with this post.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.firaMono(
                      color: Colors.white,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(83, 33, 149, 243),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: imagePlacholder,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    minimumSize: const Size(200, 35),
                  ),
                  onPressed: () async {
                    setState(() {
                      loadingIconOnUploadIMage = SizedBox(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white, size: 40),
                      );
                    });

                    int id = int.parse(widget.id);

                    PickPhotoFileWithUrlMobile img =
                        await pickPhotoMobile("/contents/$id/");
                    if (img.imageFile != null) {
                      setState(() {
                        imagePlacholder = SizedBox(
                          child: Image.file(img.imageFile!, fit: BoxFit.cover),
                        );
                      });
                    }
                    if (img.url != null) {
                      imgUrl = img.url!;
                    }
                    setState(() {
                      loadingIconOnUploadIMage = const SizedBox(
                        child: Text("Choice an Image"),
                      );
                    });
                  },
                  child: loadingIconOnUploadIMage,
                ),
                Form(
                  key: validationKey,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 20, right: 20, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: titleController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              return null;
                            } else {
                              return "Too short description";
                            }
                          },
                          decoration: InputDecoration(
                            suffix: GestureDetector(
                              child: const Icon(
                                Icons.info,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Type your topic's title",
                            labelText: "Title",
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: descriptionController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLines: null,
                          validator: (value) {
                            if (value!.length > 20) {
                              return null;
                            } else {
                              return "Too short description";
                            }
                          },
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            suffix: GestureDetector(
                              child: const Icon(
                                Icons.info,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Type your topic's description",
                            labelText: "Description",
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            publish();
                          },
                          child: loadingIconOnPublishTopics,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

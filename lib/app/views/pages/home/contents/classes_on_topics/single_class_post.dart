import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../../../../data/models/post_models.dart';
import '../../../../accounts/account_info_controller.dart';
import '../../../create_post/quill_editor/create_post_view_quill.dart';
import '../../../drawer/drawer.dart';

class SingleClassPost extends StatefulWidget {
  const SingleClassPost({
    super.key,
    required this.path,
    required this.fullData,
  });
  final String path;
  final PostModel fullData;

  @override
  State<SingleClassPost> createState() => _SingleClassPostState();
}

class _SingleClassPostState extends State<SingleClassPost> {
  final accountInfo = Get.put(AccountInfoController());
  TextEditingController commentTextController = TextEditingController();
  @override
  void initState() {
    creatWidget(widget.fullData, true);
    super.initState();
  }

  List<Widget> createCommentsWidget(Map<String, Comment> comments) {
    List<Widget> widgets = [];
    String? userMail = FirebaseAuth.instance.currentUser?.email;

    comments.forEach((key, value) {
      if (key != 'id' && key != 'commentId') {
        if (userMail == value.email) {
          widgets.add(
            Row(
              children: [
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(3),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(70, 143, 143, 143),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          value.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        value.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(60, 143, 143, 143),
                        ),
                        child: Text(
                          value.message,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          widgets.add(
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(70, 143, 143, 143),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Text(
                          value.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        value.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(60, 143, 143, 143),
                        ),
                        child: Text(
                          value.message,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }
      }
    });
    return widgets;
  }

  Widget profile = Container();
  List<Widget> post = [];
  Widget likeCommentSattus = Container();
  List<Widget> comments = [];
  List<Widget> fullPostTogether = [
    Center(
      child: LoadingAnimationWidget.dotsTriangle(color: Colors.green, size: 30),
    )
  ];

  bool isAlreadyLiked(Map<String, Like> likes) {
    bool liked = false;
    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    likes.forEach((key, value) {
      if (value.uid == userEmail) {
        liked = true;
      }
    });
    return liked;
  }

  void creatWidget(PostModel postData, bool rebuilFutuer) async {
    List<Widget> allSectionTogeter = [];
    if (rebuilFutuer == true) {
      setState(() {
        profile = Container(
          height: 73,
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(80, 143, 143, 143),
          ),
          child: FutureBuilder(
            future: FirebaseDatabase.instance
                .ref("user/${postData.ownerUid}")
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  if (snapshot.hasData) {
                    final userData =
                        jsonDecode(jsonEncode(snapshot.data!.value));
                    return Row(
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: userData['img'] == 'null'
                                ? Center(
                                    child: Text(
                                      postData.ownerName.substring(0, 2),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: userData['img'],
                                    fit: BoxFit.scaleDown,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) {
                                      return Center(
                                        child: LoadingAnimationWidget
                                            .staggeredDotsWave(
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              postData.ownerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              postData.owner,
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }
              }

              return Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Text(
                        postData.ownerName.substring(0, 2),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postData.ownerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        postData.owner,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      });
      String contentData = "";
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        try {
          final box = Hive.box("tpi_programming_club");
          contentData = box.get(postData.content).toString();
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      } else {
        final firebasePostData =
            await FirebaseDatabase.instance.ref(postData.content).get();

        if (firebasePostData.exists) {
          final data = firebasePostData.value;
          if (data != null) {
            try {
              final box = Hive.box("tpi_programming_club");
              box.put(postData.content, data.toString());
              contentData = data.toString();
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          } else {
            try {
              final box = Hive.box("tpi_programming_club");
              contentData = box.get(postData.content).toString();
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          }
        } else {
          try {
            final box = Hive.box("tpi_programming_club");
            contentData = box.get(postData.content).toString();
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        }
      }

      if (contentData.isNotEmpty) {
        if (postData.contentType == 'quill') {
          setState(() {
            post = CreatePostViewQuill().createWidgetFromString(contentData);
          });
        } else {
          TocController tocController = TocController();
          setState(() {
            post = [
              Row(
                children: [
                  Expanded(
                    child: TocWidget(controller: tocController),
                  ),
                  Expanded(
                    child: MarkdownWidget(
                      data: contentData,
                      tocController: tocController,
                    ),
                  ),
                ],
              )
            ];
          });
        }
      }
    }
    setState(() {
      comments = createCommentsWidget(widget.fullData.comments);
    });

    allSectionTogeter.add(profile);
    allSectionTogeter.addAll(post);
    allSectionTogeter.add(
      const SizedBox(
        height: 5,
      ),
    );
    allSectionTogeter.add(
      Container(
        margin: const EdgeInsets.only(left: 6, right: 6, top: 3, bottom: 3),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(80, 143, 143, 143),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: () async {
                String uid = FirebaseAuth.instance.currentUser!.uid;
                bool isDisLike = false;
                String dislikeKey = "";
                postData.likes.forEach((key, value) async {
                  if (value.uid == uid) {
                    isDisLike = true;
                    dislikeKey = key;
                  }
                });
                if (isDisLike) {
                  int likeCount = postData.likes.length;
                  likeCount--;
                  if (likeCount < 0) return;

                  await FirebaseDatabase.instance
                      .ref("${widget.path}/likes/$dislikeKey/")
                      .remove();
                  postData.likes.remove(dislikeKey);
                  creatWidget(postData, false);
                } else {
                  final date = DateTime.now();
                  Like likeData = Like(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                      date:
                          "${date.second}:${date.minute}:${date.hour} ${date.day}/${date.month}/${date.year}");
                  await FirebaseDatabase.instance
                      .ref(
                          "${widget.path}/likes/${date.millisecondsSinceEpoch}")
                      .set(likeData.toMap());
                  postData.likes.addAll(
                      {date.millisecondsSinceEpoch.toString(): likeData});

                  creatWidget(postData, false);
                }
              },
              icon: isAlreadyLiked(postData.likes)
                  ? const Icon(
                      Icons.thumb_up,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.thumb_up,
                      color: Colors.grey,
                    ),
              label: Text(
                (widget.fullData.likes.length - 1).toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Scaffold(
                      body: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextFormField(
                                  controller: commentTextController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.cancel),
                                      label: const Text("Cancle"),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        final time = DateTime.now();
                                        Comment comment = Comment(
                                          profile: accountInfo.img.value,
                                          email: FirebaseAuth
                                              .instance.currentUser!.email
                                              .toString(),
                                          date:
                                              "Date: ${time.day}/${time.month}/${time.year} at ${time.hour}:${time.minute}:${time.second}",
                                          uid: FirebaseAuth
                                              .instance.currentUser!.uid,
                                          message:
                                              commentTextController.text.trim(),
                                        );

                                        await FirebaseDatabase.instance
                                            .ref(
                                                "${widget.path}/comments/${time.millisecondsSinceEpoch}")
                                            .set(comment.toMap());
                                        commentTextController.clear();
                                        postData.comments.addAll({
                                          time.microsecondsSinceEpoch
                                              .toString(): comment
                                        });
                                        creatWidget(postData, false);
                                      },
                                      icon: const Icon(Icons.done),
                                      label: const Text("Ok"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.comment,
                color: Colors.green,
              ),
              label: Text(
                (postData.comments.length - 1).toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    allSectionTogeter.addAll([
      const SizedBox(
        height: 5,
      ),
      const Center(
        child: Text("Comments"),
      ),
      const SizedBox(
        height: 5,
      ),
    ]);

    allSectionTogeter.addAll(comments);
    setState(() {
      fullPostTogether = allSectionTogeter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fullData.title,
        ),
      ),
      drawer: const HomeDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(5),
        children: fullPostTogether,
      ),
    );
  }
}

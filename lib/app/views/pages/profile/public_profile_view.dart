// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/show_toast_meassage.dart';
import '../../../data/models/account_model.dart';

class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({super.key, required this.uid});
  final String uid;

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  IconData postHideIcon = Icons.keyboard_arrow_right;
  IconData fllowersHideIcon = Icons.keyboard_arrow_right;
  Widget mainWidget = const Center(child: CircularProgressIndicator());
  String fllowText = "Follow";
  late AccountModel userModel;

  void buildWidget() {
    Widget temWidget = ListView(
      children: [
        Center(
          child: Container(
            height: 150,
            width: 150,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.green.shade300,
            ),
            child: userModel.img == 'null'
                ? Center(
                    child: Text(
                      userModel.userName.substring(0, 2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: userModel.img,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
          ),
        ),
        const Divider(),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            const Icon(
              Icons.person,
              size: 36,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              userModel.userName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
        const Divider(),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            const Icon(
              Icons.email,
              size: 33,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              userModel.userEmail,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            const CircleAvatar(
              radius: 15,
              child: Text("ID"),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              FirebaseAuth.instance.currentUser!.uid,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(),
        widget.uid != FirebaseAuth.instance.currentUser!.uid
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser!;
                        final userRef =
                            FirebaseDatabase.instance.ref('user/${user.uid}/');

                        if (userModel.followers.contains(widget.uid)) {
                          userModel.followers.remove(widget.uid);
                          setState(() {
                            fllowText = "Follow";
                          });
                          buildWidget();
                        } else {
                          userModel.followers.add(widget.uid);
                          setState(() {
                            fllowText = "Unfollow";
                          });
                          buildWidget();
                        }
                        await userRef.update(userModel.toJson());
                      },
                      child: Text(fllowText)),
                  const SizedBox(
                    width: 15,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => const Center(
                            child: Text(
                              "Feature is under developemnt",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.message),
                      label: const Text("Message"))
                ],
              )
            : const SizedBox(),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 1,
            ),
            Text("User ${userModel.posts.length} Posts"),
            Container(
              height: 3,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.green,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  postHideIcon == Icons.keyboard_arrow_down
                      ? postHideIcon = Icons.keyboard_arrow_right
                      : postHideIcon = Icons.keyboard_arrow_down;
                });
                buildWidget();
              },
              icon: Icon(
                postHideIcon,
                size: 34,
              ),
            ),
          ],
        ),
      ],
    );

    setState(() {
      mainWidget = temWidget;
    });
  }

  void getData() async {
    try {
      final data =
          await FirebaseDatabase.instance.ref("/user/${widget.uid}").get();
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(jsonDecode(jsonEncode(data.value)));
      userModel = AccountModel(
        userName: userData['userName'],
        userEmail: userData['userEmail'],
        img: userData['img'] ?? "null",
        posts: userData['posts'] ?? [],
        followers: userData['followers'] ?? [],
        uid: widget.uid,
        allowMessages: userData['allowMessages'] ?? false,
      );
      if (userModel.followers.contains(widget.uid)) {
        setState(() {
          fllowText = "Unfollow";
        });
      }
      buildWidget();
    } catch (e) {
      setState(() {
        mainWidget = const Center(
          child: Text("Someting Went wrong"),
        );
      });
      showToast(e.toString());
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainWidget,
    );
  }
}

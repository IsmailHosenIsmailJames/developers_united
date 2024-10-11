import 'package:developers_united/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 20,
              child: PageView(
                onPageChanged: (value) {
                  setState(() {
                    pageIndex = value;
                  });
                },
                children: [
                  generatePage(
                    assetsPath: "assets/login_page/laptop_and_coffe.jpg",
                    title: "Comprehensive Tutorials & Learning Resources",
                    description:
                        "Whether you're learning a new language, framework, or tackling complex algorithms, the app will feature an extensive library of tutorials designed by experienced programmers. These tutorials will cover various topics, from beginner-level introductions to advanced deep-dives into modern technologies. Users can follow step-by-step guides, watch instructional videos, and practice coding with integrated exercises. As a bonus, tutorials will be updated regularly to reflect the latest trends and industry standards.",
                  ),
                  generatePage(
                    assetsPath:
                        "assets/login_page/Collaborative-Coding.-A-developer-team-working-together.-min.webp",
                    title: "Problem Posting & Collaborative Solutions",
                    description:
                        "In this section, users can post programming challenges, errors, or bugs they're encountering in their projects. Fellow programmers, ranging from beginners to experts, can engage by providing solutions, sharing insights, and offering guidance. The collaborative nature of this feature allows users to benefit from a diverse range of approaches and problem-solving techniques. With a voting system, the most effective solutions can be highlighted, ensuring users receive accurate and efficient help.",
                  ),
                  generatePage(
                    assetsPath: "assets/login_page/NET-Developer–Team-Lead.jpg",
                    title: "Programmer Networking & Community Building",
                    description:
                        "The app will offer a dedicated space for programmers to connect, exchange ideas, and build meaningful relationships. Users can follow each other, collaborate on projects, or participate in coding challenges and discussions. By facilitating networking opportunities, the platform will help users find mentors, teammates for open-source projects, or even job opportunities. The community features are designed to foster a supportive and growth-oriented environment.",
                  ),
                  generatePage(
                    assetsPath: "assets/login_page/maxresdefault.jpg",
                    title: "Expert Assistance & Mentorship",
                    description:
                        "For users seeking more in-depth support, the app will provide access to a pool of expert programmers who can offer personalized guidance. Whether you're stuck on a particularly difficult problem or need career advice, expert mentors will be available for one-on-one sessions, code reviews, and project feedback. This feature is designed to help developers accelerate their learning and achieve their goals with expert help tailored to their specific needs.",
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: index == pageIndex ? 8 : 5,
                      backgroundColor: index == pageIndex
                          ? AppColors().elevatedButtomBackgroundColor
                          : null,
                    ),
                  );
                },
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Register"),
                    ),
                  ),
                  const Gap(20),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Sign in"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget generatePage({
    required String assetsPath,
    required String title,
    required String description,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(
                  assetsPath,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

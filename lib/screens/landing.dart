import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:event_go/constant/color.dart';
import 'package:google_fonts/google_fonts.dart';

final h1 = GoogleFonts.poppins(
  color: const Color.fromARGB(255, 255, 255, 255),
  fontSize: 60,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.75,
);

final h2 = GoogleFonts.poppins(
  color: const Color.fromARGB(255, 255, 255, 255),
  fontSize: 20,
  fontWeight: FontWeight.w700,
);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image with Blur Effect
            Positioned.fill(
              child: ClipRect(
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/concert-background-photo.jpg",
                      alignment: const Alignment(-0.02, 0.78),
                      height: size.height,
                      fit: BoxFit.none,
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.2), // Light overlay
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text Content (Heading & Subheading)
            Positioned(
              top: size.height * 0.17,
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      // Main Headings
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Discover.\nConnect.\nExperience.",
                            style: h1,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Your Local Events, All in One \nPlace!",
                            style: h2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),

                      // Background Color (Marble) Container
                      Container(
                        alignment: Alignment.bottomLeft,
                        width: size.width,
                        height: size.height,
                        decoration: const BoxDecoration(
                          color: marble,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                "One Tap Away!",
                                style: GoogleFonts.poppins(
                                  color: bark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Unlock The Best Local Experiences",
                                style: GoogleFonts.poppins(
                                  color: bark,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Center(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                                horizontal: size.width * 0.1,
                                                vertical: size.width * 0.05)),
                                        backgroundColor:
                                            WidgetStateProperty.all(bark)),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: Text(
                                      "Get Started",
                                      style: GoogleFonts.poppins(
                                          color: marble,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:event_go/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool isVisible = false;

    return Scaffold(
      backgroundColor: ethereal,
      appBar: AppBar(
        backgroundColor: marble,
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: double.infinity,
              height: size.height * 0.2,
              decoration: const BoxDecoration(
                  color: marble,
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(100))),
              child: Container(
                alignment: Alignment(-size.width * 0.0015, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome \nBack",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 40,
                          color: bark),
                    ),
                    Text(
                      "Explore Events Around You!",
                      style: GoogleFonts.poppins(
                          color: bark,
                          fontWeight: FontWeight.normal,
                          fontSize: 15),
                    )
                  ],
                ),
              )),
          const SizedBox(
            height: 100,
          ),
          Center(
            child: SizedBox(
                width: size.width * 0.75,
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      autocorrect: true,
                      decoration: InputDecoration(
                          label: Text(
                        "Email",
                        style: GoogleFonts.poppins(
                            color: bark, fontWeight: FontWeight.w700),
                      )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      obscureText: !isVisible,
                      controller: _passwordController,
                      autocorrect: true,
                      decoration: InputDecoration(
                          label: Text(
                        "Password",
                        style: GoogleFonts.poppins(
                            color: bark, fontWeight: FontWeight.w700),
                      )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                        iconAlignment: IconAlignment.end,
                        onPressed: () => {},
                        child: const Text(
                          "Forgot Password?",
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(bark)),
                        onPressed: () => {},
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: ethereal,
                            fontSize: 20,
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "OR",
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 230))),
                      onPressed: () => {},
                      child: Row(
                        children: [
                          Text(
                            "Sign in With Google",
                            style: GoogleFonts.poppins(),
                          )
                        ],
                      ),
                    )
                  ],
                )),
          )
        ],
      )),
    );
  }
}

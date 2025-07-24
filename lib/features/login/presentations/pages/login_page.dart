import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rebill_flutter/core/constants/app_constants.dart';
import 'package:rebill_flutter/core/providers/orientation_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';

final usernameProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');

final obscureProvider = StateProvider<bool>((ref) => true);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = ref.watch(orientationProvider);

    return Scaffold(
      body:
          isLandscape
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context),
    );
  }

  /// PORTRAIT WIDGET BUILDER
  Widget _buildPortraitLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: const Alignment(0.0, -1.3),
                    image: const AssetImage('assets/images/bgLogin2.jpg'),
                    colorFilter: ColorFilter.mode(
                      Colors.blue.withOpacity(0.75),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _buildLoginForm(theme, _usernameController),
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

  //LANDSCAPE WIDGET BUILDER
  Widget _buildLandscapeLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/bgLogin2.jpg'),
              alignment: Alignment(-4, 0),
              colorFilter: ColorFilter.mode(
                Colors.blue.withOpacity(0.75),
                BlendMode.srcATop,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: Container()),
              //Right Form
              Expanded(
                flex: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      bottomLeft: Radius.circular(35),
                    ),
                  ),
                  child: Center(
                    child: _buildLoginForm(theme, _usernameController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// WIDGET LOGIN FORM
  Widget _buildLoginForm(
    ThemeData theme,
    TextEditingController usernameController,
  ) {
    final isLandscape = ref.watch(orientationProvider);
    final isObscure = ref.watch(obscureProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.blueAccent, size: 50),
              const SizedBox(width: 8),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Re',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 104, 98, 98),
                      ),
                    ),
                    TextSpan(
                      text: 'Bill',
                      style: TextStyle(fontSize: 45, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to your account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),

          // White Box in Container
          Container(
            width:
                isLandscape
                    ? MediaQuery.of(context).size.width * 0.4
                    : MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5), // Bayangan di bawah
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),

            // Form Fields Username and Password
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    hintText: 'Email Address or Username',
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                    hintText: 'Password',
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        ref.read(obscureProvider.notifier).state =
                            !isObscure; // Toggle password visibility
                      },
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blueGrey,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 25),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: () {},
                        text: 'Login Dashboard',
                        disabled: false,
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "or",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        onPressed: () {
                          ref.read(usernameProvider.notifier).state =
                              usernameController.text;
                          context.go(AppConstants.homeRoute);
                        },
                        text: 'Login POS',
                        disabled: false,
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

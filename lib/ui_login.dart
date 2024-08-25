import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:test_4_login/error.dart';
import 'package:test_4_login/ui_data.dart';
import 'package:test_4_login/utils/utils.dart';

import 'sign.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorAccount;
  String? errorPass;
  String error = '';

  TextEditingController cAccount = TextEditingController();
  TextEditingController cPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _bgr(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                LoginTextField(
                  controller: cAccount,
                  hintText: 'Tài khoản',
                  errorText: errorAccount,
                  prefixIcon: const Icon(Icons.person),
                ),
                const SizedBox(height: 20),
                LoginTextField(
                  controller: cPass,
                  hintText: 'Mật khẩu',
                  errorText: errorPass,
                  prefixIcon: const Icon(Icons.lock),
                  isPassWord: true,
                ),
                const SizedBox(height: 20),
                ErrorMessage(error: error),
                const SizedBox(height: 20),
                LoginButtons(
                  cAccount: cAccount,
                  cPass: cPass,
                  onError: (String errorMsg) {
                    setState(() {
                      error = errorMsg;
                    });
                  },
                ),
                const SizedBox(height: 10),
                RegisterAndForgotPasswordWidget(
                  create: () {
                    createUser(cAccount.text, cPass.text);
                  },
                  onError: (String errorMsg) {
                    setState(() {
                      error = errorMsg;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SocialLoginButtons(onError: (String errorMsg) {
                  setState(() {
                    error = errorMsg;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bgr() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Image.asset(
        'assets/images/bgr_login.png',
        fit: BoxFit.fill,
      ),
    );
  }
}

class RegisterAndForgotPasswordWidget extends StatelessWidget {
  const RegisterAndForgotPasswordWidget(
      {super.key, required this.onError, required this.create});
  final Function(String) onError;
  final Function create;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            create();
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Đăng ký',
              style: TextStyle(
                color: Colors.blue,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () async {},
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Lấy lại mật khẩu',
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String error;
  const ErrorMessage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return error.isNotEmpty
        ? Text(
            error,
            style: const TextStyle(color: Colors.red),
          )
        : const SizedBox();
  }
}

class LoginTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final Widget prefixIcon;
  final bool isPassWord;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    required this.prefixIcon,
    this.isPassWord = false,
  });

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool showPass = false;

  void _changeObscureText() {
    setState(() {
      showPass = !showPass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: showPass,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassWord ? _buttonShowPass() : null,
        errorText: widget.errorText,
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buttonShowPass() {
    return IconButton(
        onPressed: () => _changeObscureText(),
        icon: showPass
            ? const Icon(Icons.visibility)
            : const Icon(Icons.visibility_off));
  }
}

class LoginButtons extends StatelessWidget {
  final TextEditingController cAccount;
  final TextEditingController cPass;
  final Function(String) onError;

  const LoginButtons({
    super.key,
    required this.cAccount,
    required this.cPass,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll((Color(0xFFF27522))),
            ),
            onPressed: () async {
              try {
                final user =
                    await signInWithEmailAndPass(cAccount.text, cPass.text);
                Utils.showToast(context,
                    'Đăng nhập thành công ${user?.user?.email} ${user?.user?.uid}');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
              } catch (e) {
                if (e is ErorrBase) {
                  onError('${e.message} : ${e.code}');
                }
              }
            },
            child: const Text(
              'Đăng nhập',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class SocialLoginButtons extends StatelessWidget {
  final Function(String) onError;

  const SocialLoginButtons({super.key, required this.onError});

  void _loginGoogle(BuildContext context) async {
    final data = await signInWithGoogle();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
    if (data == null) {
      onError('Lỗi đăng nhập Google');
    }
  }

  void _loginApple() async {}

  void _loginFaceBook() async {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Đăng nhập với'),
            ),
            Expanded(
              child: Divider(
                color: Colors.black,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buttonIcon(Icons.facebook, _loginFaceBook, Colors.blue),
            _buttonIcon(Icons.apple, _loginApple, Colors.black),
            _buttonIcon(Icons.g_mobiledata_rounded, () => _loginGoogle(context),
                Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buttonIcon(IconData iconData, Function fct, Color color) {
    return InkWell(
      onTap: () => fct(),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: color),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Icon(
            iconData,
            color: color,
            size: 42,
          ),
        ),
      ),
    );
  }
}

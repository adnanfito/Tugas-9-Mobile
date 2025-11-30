import 'package:flutter/material.dart';
import 'package:tokokita/bloc/login_bloc.dart';
import 'package:tokokita/helpers/user_info.dart';
import 'package:tokokita/ui/produk_page.dart';
import 'package:tokokita/ui/registrasi_page.dart';
import 'package:tokokita/widget/warning_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _emailTextboxController = TextEditingController();
  final _passwordTextboxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _emailTextField(),
                _passwordTextField(),
                _buttonLogin(),
                const SizedBox(height: 30),
                _menuRegistrasi(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Email"),
      keyboardType: TextInputType.emailAddress,
      controller: _emailTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email harus diisi';
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Password"),
      keyboardType: TextInputType.text,
      obscureText: true,
      controller: _passwordTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password harus diisi";
        }
        return null;
      },
    );
  }

  Widget _buttonLogin() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () {
              var validate = _formKey.currentState!.validate();
              if (validate) {
                _submit();
              }
            },
      child: const Text("Login"),
    );
  }

  void _submit() {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    print('🔵 [LoginPage] Starting login...');

    LoginBloc.login(
      email: _emailTextboxController.text,
      password: _passwordTextboxController.text,
    ).then(
      (value) async {
        print(
          '🟢 [LoginPage] Login response: code=${value.code}, token=${value.token}, userID=${value.userID}',
        );

        // ✅ Check apakah code adalah 200 DAN token tidak kosong
        if (value.code == 200 &&
            value.token != null &&
            value.token!.isNotEmpty) {
          try {
            print('🟡 [LoginPage] Saving token: ${value.token}');
            await UserInfo().setToken(value.token!);

            print('🟡 [LoginPage] Saving userID: ${value.userID}');
            await UserInfo().setUserID(int.parse(value.userID ?? '0'));

            // ✅ Tunggu sebentar agar data tersimpan
            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              print('🟣 [LoginPage] Navigating to ProdukPage...');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProdukPage()),
              );
            }
          } catch (e) {
            print('❌ [LoginPage] Error saving user data: $e');
            setState(() {
              _isLoading = false;
            });

            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => const WarningDialog(
                  description: "Gagal menyimpan data, silahkan coba lagi",
                ),
              );
            }
          }
        } else {
          print(
            '🔴 [LoginPage] Login failed: code=${value.code}, status=${value.status}',
          );
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => WarningDialog(
                description: value.message ?? "Login gagal, silahkan coba lagi",
              ),
            );
          }
        }
      },
      onError: (error) {
        print('🔴 [LoginPage] Login error: $error');
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => const WarningDialog(
              description: "Login gagal, silahkan coba lagi",
            ),
          );
        }
      },
    );
  }

  Widget _menuRegistrasi() {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegistrasiPage()),
          );
        },
        child: const Text("Registrasi", style: TextStyle(color: Colors.blue)),
      ),
    );
  }

  @override
  void dispose() {
    _emailTextboxController.dispose();
    _passwordTextboxController.dispose();
    super.dispose();
  }
}

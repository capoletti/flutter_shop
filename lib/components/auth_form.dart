import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';

import '../models/auth.dart';

enum AuthMode { signup, login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authmode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  bool _isLogin() => _authmode == AuthMode.login;
  bool _isSignup() => _authmode == AuthMode.signup;

  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    //_heightAnimation?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authmode = AuthMode.signup;
        _controller?.forward();
      } else {
        _authmode = AuthMode.login;
        _controller?.reverse();
      }
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);

    try {
      if (_isLogin()) {
        await auth.login(_authData['email']!, _authData['password']!);
      }

      if (_isSignup()) {
        await auth.signup(_authData['email']!, _authData['password']!);
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('ocorreu um erro inesperado!');
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ocorreu um erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      color: Colors.white70,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: AnimatedContainer(
        //AnimatedBuilder(
        //animation: _heightAnimation!,
        //builder: (ctx, childForm) => Container(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
        padding: const EdgeInsets.all(16),
        height: _isLogin() ? 310 : 400,
        //height: _heightAnimation?.value.height ?? (_isLogin() ? 310 : 400),
        width: deviceSize.width * 0.80,

        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'e-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (email) {
                  email = email ?? '';
                  if (email.isEmpty) {
                    return 'informar o email';
                  }
                  return null;
                },
                onSaved: (email) => _authData['email'] = email ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'senha'),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: _passwordController,
                validator: (password) {
                  password = password ?? '';
                  if (password.isEmpty) {
                    return 'informar a senha';
                  }
                  return null;
                },
                onSaved: (password) => _authData['password'] = password ?? '',
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: _isLogin() ? 0 : 120,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'confirmar senha'),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (password) {
                        password = password ?? '';
                        if (_isSignup()) {
                          if (password != _passwordController.text) {
                            return 'senhas diferentes';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  child: Text(_isLogin() ? 'ENTRAR' : 'REGISTRAR'),
                ),
              const Spacer(),
              if (!_isLoading)
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      _isLogin() ? 'DESEJA REGISTRAR?' : 'JÁ POSSUI CONTA?'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

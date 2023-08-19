import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../../domain/enums.dart';
import '../../../routes/routes.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  String _username = '', _password = '';
  bool _fetching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: AbsorbPointer(
            absorbing: _fetching,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (text) {
                    setState(() {
                      _username = text.toLowerCase().trim();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'username',
                  ),
                  validator: (text) {
                    text = text?.trim().toLowerCase() ?? '';

                    if (text.isEmpty) {
                      return 'Invalid username';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (text) {
                    setState(() {
                      _password = text.replaceAll(' ', '').toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'password',
                  ),
                  validator: (text) {
                    text = text?.replaceAll(' ', '').toLowerCase() ?? '';

                    if (text.length < 4) {
                      return 'Invalid password';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Builder(
                        builder: (context) {
                          if (_fetching) {
                            return const CircularProgressIndicator();
                          }
                          return MaterialButton(
                            onPressed: () {
                              final isValid = Form.of(context).validate();

                              if (isValid) {
                                _submit(context);
                              }
                            },
                            color: Colors.blue,
                            child: const Text('Sign in'),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _fetching = true;
    });
    final result = await Injector.of(context).authenticationRepository.signIn(
          _username,
          _password,
        );

    if (!mounted) {
      return;
    }

    result.when(
      (failure) {
        setState(() {
          _fetching = false;
        });

        final message = {
          SignInFailure.notFound: 'Not Found',
          SignInFailure.unauthorized: 'Invalid password',
          SignInFailure.unknown: 'Error',
        }[failure];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message!),
          ),
        );
      },
      (user) {
        Navigator.pushReplacementNamed(
          context,
          Routes.home,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:openprices/model/dao_secured_string.dart';
import 'package:openprices/model/openpricesapiclient2.dart';
import 'package:openprices/ui/common.dart';

const String daoSecuredStringTagUser = 'user';
const String daoSecuredStringTagToken = 'token';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  static const String _daoSecuredStringTagPassword = 'password';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userController.text =
        await DaoSecuredString.get(daoSecuredStringTagUser) ?? '';
    _passwordController.text =
        await DaoSecuredString.get(_daoSecuredStringTagPassword) ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('User'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _userController,
                decoration: getDecoration(
                  hintText: 'User',
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: getDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    tooltip: 'Show password',
                    splashRadius: 10.0,
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    icon: _obscurePassword
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.maxFinite,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final ScaffoldMessengerState state =
                        ScaffoldMessenger.of(context);
                    state.showSnackBar(
                      const SnackBar(content: Text('Logging in...')),
                    );
                    final String user = _userController.text;
                    final String password = _passwordController.text;
                    await DaoSecuredString.put(
                      key: daoSecuredStringTagUser,
                      value: user,
                    );
                    await DaoSecuredString.put(
                      key: _daoSecuredStringTagPassword,
                      value: password,
                    );
                    try {
                      final String token =
                          await OpenPricesAPIClient2.getAuthenticationToken(
                        username: user,
                        password: password,
                      );
                      await DaoSecuredString.put(
                        key: daoSecuredStringTagToken,
                        value: token,
                      );
                      state.showSnackBar(
                        const SnackBar(content: Text('Log in successful!')),
                      );
                    } catch (e) {
                      state.showSnackBar(
                        SnackBar(content: Text('Could not log in: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Log in!'),
                ),
              ),
            ),
          ],
        ),
      );
}

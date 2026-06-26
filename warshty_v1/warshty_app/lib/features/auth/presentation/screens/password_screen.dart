import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == '5555') {
      context.go('/home');
    } else {
      setState(() => _error = 'كلمة المرور غير صحيحة');
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.spacing24),
            child: AnimatedBuilder(
              animation: _shakeCtrl,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  (_shake.value == 1 ? 0 : _shake.value * 20),
                  0,
                ),
                child: child,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.handyman_rounded,
                    color: context.accentColor,
                    size: 56,
                  ),
                  SizedBox(height: AppConstants.spacing16),
                  Text('ورشتي', style: AppTextStyles.loginTitle(context)),
                  SizedBox(height: AppConstants.spacing8),
                  Text(
                    'أدخل كلمة المرور',
                    style: AppTextStyles.balanceLabel(context).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacing40),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.formInput(context).copyWith(
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: '• • • •',
                      errorText: _error,
                      errorStyle: AppTextStyles.formLabel(context).copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _submit(),
                  ),
                  SizedBox(height: AppConstants.spacing24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text('دخول', style: AppTextStyles.loginButton(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

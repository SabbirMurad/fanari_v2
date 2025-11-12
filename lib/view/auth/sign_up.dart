import 'dart:async';

import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/view/auth/reusable/input_message.dart';
import 'package:fanari_v2/widgets/input_field_v_one.dart';
import 'package:fanari_v2/widgets/primary_button.dart';
import 'package:fanari_v2/widgets/svg_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fanari_v2/utils.dart' as utils;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _loading = false;
  int _selectedIndex = 0;

  final _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _pageController.dispose();

    _timer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      if (_emailController.text.isEmpty) {
        setState(() {
          _emailUnique = false;
          _validEmail = false;
        });
        return;
      }
      _validateEmail(_emailController.text);
    });

    _usernameController.addListener(() {
      if (_usernameController.text.isEmpty) {
        setState(() {
          _usernameUnique = false;
          _usernameValid = false;
        });
        return;
      }

      _validateUsername(_usernameController.text);
    });

    _passwordController.addListener(() {
      if (_passwordController.text.isEmpty) {
        setState(() {
          _passwordValid = false;
          _passwordEmpty = true;
          _passwordStrength = 0;
        });
        return;
      }

      setState(() {
        _passwordEmpty = false;
        _passwordValid = _passwordController.text.length >= 6;
        _passwordStrength = passwordStrength(_passwordController.text);
      });

      if (_passwordValid) {
        setState(() {
          _passwordMatch =
              _passwordController.text == _confirmPasswordController.text;
        });
      }
    });

    _confirmPasswordController.addListener(() {
      if (_confirmPasswordController.text.isEmpty) {
        setState(() {
          _passwordMatch = false;
        });
        return;
      }

      setState(() {
        _passwordMatch =
            _passwordController.text == _confirmPasswordController.text;
      });
    });
  }

  _validateUsername(String value) {
    setState(() {
      _username6Char = value.length >= 6 && value.length <= 32;
      _usernameValid = isLowercaseNumberOrUnderscore(value);
      _usernameUnique = false;
    });

    if (_usernameValid) {
      _checkUsernameAvailability(value);
    }
  }

  _checkUsernameAvailability(String value) {
    _timer?.cancel();

    _timer = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _checkingUsernameAvailability = true;
      });

      final response = await utils.CustomHttp.get(
        endpoint: '/auth/user/${value}',
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode != 200) {
        setState(() {
          _checkingUsernameAvailability = false;
          _usernameUnique = true;
        });
        return;
      }

      setState(() {
        _checkingUsernameAvailability = false;
        _usernameUnique = false;
      });
    });
  }

  bool isLowercaseNumberOrUnderscore(String input) {
    final regex = RegExp(r'^[a-z0-9_]+$');
    return regex.hasMatch(input);
  }

  _validateEmail(String value) {
    setState(() {
      _validEmail = utils.isValidEmail(value);
      _emailUnique = false;
    });

    if (_validEmail) {
      _checkEmailAvailability(value);
    }
  }

  Timer? _timer;

  _checkEmailAvailability(String value) {
    _timer?.cancel();

    _timer = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _checkingEmailAvailability = true;
      });

      final response = await utils.CustomHttp.get(
        endpoint: '/auth/user/${value}',
        needAuth: false,
        showFloatingError: false,
      );

      if (response.statusCode != 200) {
        setState(() {
          _checkingEmailAvailability = false;
          _emailUnique = true;
        });
        return;
      }

      setState(() {
        _checkingEmailAvailability = false;
        _emailUnique = false;
      });
    });
  }

  void _goToPreviousPage() {
    setState(() {
      _selectedIndex--;
    });

    _pageController.animateToPage(
      _selectedIndex,
      duration: const Duration(milliseconds: 272),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextPage() {
    setState(() {
      _selectedIndex++;
    });

    _pageController.animateToPage(
      _selectedIndex,
      duration: const Duration(milliseconds: 272),
      curve: Curves.easeInOut,
    );
  }

  Widget _nameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 72.h),
        InputFieldVOne(
          hintText: 'First name',
          controller: _firstNameController,
        ),
        SizedBox(height: 24.h),
        InputFieldVOne(hintText: 'Last Name', controller: _lastNameController),
        SizedBox(height: 56.h),
        PrimaryButton(
          loading: _loading,
          text: 'Next',
          onTap: () {
            if (_firstNameController.text.isEmpty) {
              utils.showCustomToast(text: 'Please enter your first name.');
              return;
            }

            if (_lastNameController.text.isEmpty) {
              utils.showCustomToast(text: 'Please enter your last name.');
              return;
            }

            _goToNextPage();
          },
          width: 130.w,
        ),
        SizedBox(height: 0.04.sh),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: (1.sw * 0.5) - 72.w,
                height: 1,
                color: Colors.grey,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: (1.sw * 0.5) - 72.w,
                height: 1,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have account?',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () => AppRoutes.push(AppRoutes.sign_in),
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _validEmail = false;
  bool _checkingEmailAvailability = false;
  bool _emailUnique = false;

  Widget _enterEmailWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 72.h),
        InputFieldVOne(hintText: 'Email Address', controller: _emailController),
        Padding(
          padding: EdgeInsets.only(top: 12.h, left: 6.w),
          child: Column(
            children: [
              InputMessage(
                type: _validEmail
                    ? InputMessageType.ok
                    : InputMessageType.error,
                text: 'Valid email address',
              ),
              InputMessage(
                type: _checkingEmailAvailability
                    ? InputMessageType.loading
                    : _emailUnique
                    ? InputMessageType.ok
                    : InputMessageType.error,
                text: 'Doesn\'t have a previously registered account',
              ),
            ],
          ),
        ),
        SizedBox(height: 56.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                _goToPreviousPage();
              },
              icon: Text(
                'Go Back',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 28.w),
            PrimaryButton(
              loading: _loading,
              text: 'Next',
              enabled: _emailUnique && _validEmail,
              onTap: () {
                setState(() {
                  _selectedEmail = _emailController.text.trim();
                });

                _goToNextPage();
              },
              width: 130.w,
            ),
          ],
        ),
      ],
    );
  }

  bool _username6Char = false;
  bool _usernameValid = false;
  bool _usernameUnique = false;
  bool _checkingUsernameAvailability = false;

  Widget _enterUsernameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 72.h),
        InputFieldVOne(hintText: 'Username', controller: _usernameController),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 6),
          child: Column(
            children: [
              InputMessage(
                type: _username6Char
                    ? InputMessageType.ok
                    : InputMessageType.error,
                text: 'Within 6 to 32 chars.',
              ),
              InputMessage(
                type: _usernameValid
                    ? InputMessageType.ok
                    : InputMessageType.error,
                text: 'Only a to z, 0 to 9 or _.',
              ),
              InputMessage(
                type: _checkingUsernameAvailability
                    ? InputMessageType.loading
                    : _usernameUnique
                    ? InputMessageType.ok
                    : InputMessageType.error,
                text: 'Doesn\'t have a previously registered account.',
              ),
            ],
          ),
        ),
        SizedBox(height: 56.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                _goToPreviousPage();
              },
              icon: Text(
                'Go Back',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 28.w),
            PrimaryButton(
              loading: _loading,
              text: 'Next',
              enabled: _usernameUnique && _usernameValid && _username6Char,
              onTap: () {
                _goToNextPage();
              },
              width: 130.w,
            ),
          ],
        ),
      ],
    );
  }

  bool _passwordValid = false;
  bool _passwordMatch = false;
  int _passwordStrength = 0;
  bool _passwordEmpty = true;

  String _createdAccountId = '';
  String _selectedEmail = '';

  Future<void> _createAccount() async {
    final body = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email_address': _emailController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'confirm_password': _passwordController.text,
    };

    setState(() {
      _loading = true;
    });

    final response = await utils.CustomHttp.post(
      endpoint: '/auth/sign-up',
      body: body,
      needAuth: false,
    );

    if (response.statusCode == 200) {
      setState(() {
        _createdAccountId = response.data['user_id'];
      });

      _goToNextPage();
    }

    setState(() {
      _loading = false;
    });
  }

  Widget _enterPasswordWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 72.h),
        InputFieldVOne(hintText: 'Password', controller: _passwordController),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 6),
          child: Column(
            children: [
              InputMessage(
                type: _passwordValid
                    ? InputMessageType.ok
                    : InputMessageType.error,
                text: 'At least 6 char or more.',
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        InputFieldVOne(
          hintText: 'Confirm password',
          controller: _confirmPasswordController,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 6),
          child: Column(
            children: [
              InputMessage(
                type: _passwordMatch
                    ? InputMessageType.ok
                    : InputMessageType.error,
                text: 'Matches with password.',
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(
          _passwordStrength == 0
              ? 'Very Weak'
              : _passwordStrength == 1
              ? 'Weak'
              : _passwordStrength == 2
              ? 'Medium'
              : _passwordStrength == 3
              ? 'Strong'
              : 'Very Strong',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            return Container(
              width: (1.sw - 48.w - (8 * 4)) / 5,
              height: 8.w,
              decoration: BoxDecoration(
                color: (_passwordStrength < index || _passwordEmpty)
                    ? AppColors.secondary
                    : _passwordStrengthColors[_passwordStrength],
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        SizedBox(height: 56.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                _goToPreviousPage();
              },
              icon: Text(
                'Go Back',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 28.w),
            PrimaryButton(
              loading: _loading,
              text: 'Next',
              enabled: _passwordValid && _passwordMatch,
              onTap: _createAccount,
              width: 130.w,
            ),
          ],
        ),
      ],
    );
  }

  String _otp = '';

  Future<void> _verifyAccount() async {
    setState(() {
      _loading = true;
    });

    final body = {'user_id': _createdAccountId, 'verification_code': _otp};

    final response = await utils.CustomHttp.post(
      endpoint: '/auth/validate-email',
      body: body,
      needAuth: false,
    );

    setState(() {
      _loading = false;
    });

    if (response.statusCode == 200) {
      final localStorage = await SharedPreferences.getInstance();
      localStorage.setString('access_token', response.data['access_token']);
      localStorage.setInt(
        'access_token_valid_till',
        response.data['access_token_valid_till'],
      );

      AppRoutes.go(AppRoutes.feed);
    }
  }

  Widget _verificationWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 72.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Please provide the 6 digit verification code we sent to',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              WidgetSpan(child: SizedBox(width: 6.w)),
              TextSpan(
                text: _selectedEmail,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        OtpTextField(
          numberOfFields: 6,
          cursorColor: AppColors.text,
          fillColor: AppColors.secondary,
          filled: true,
          focusedBorderColor: AppColors.primary.withValues(alpha: 0.1),
          enabledBorderColor: Colors.transparent,
          showFieldAsBox: true,
          borderRadius: BorderRadius.circular(12.r),
          fieldWidth: 48.w,
          borderWidth: 1.5,
          fieldHeight: 48.w,
          textStyle: TextStyle(
            color: AppColors.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          onCodeChanged: (String code) {},
          onSubmit: (String verificationCode) {
            setState(() {
              _otp = verificationCode;
            });
          },
        ),
        SizedBox(height: 24.h),
        Text(
          'Change email address?',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 56.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrimaryButton(
              loading: _loading,
              text: 'Next',
              enabled: _otp.length == 6,
              onTap: _verifyAccount,
              width: 130.w,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.12.sh),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Svg.asset(
                    'assets/icons/logo.svg',
                    width: 28.w,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12.h),
                  Text(
                    'Fanari',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.08.sh),
              Text(
                'Sign Up',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Create a account to get started with your journey',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                height: 0.55.sh,
                child: PageView(
                  controller: _pageController,
                  children: [
                    _nameWidget(),
                    _enterEmailWidget(),
                    _enterUsernameWidget(),
                    _enterPasswordWidget(),
                    _verificationWidget(),
                  ],
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSmoothIndicator(
                    count: 5,
                    activeIndex: _selectedIndex,
                    duration: const Duration(milliseconds: 372),
                    curve: Curves.easeInOut,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.secondary,
                      dotWidth: 8,
                      dotHeight: 8,
                      spacing: 8,
                      expansionFactor: 2.5,
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

  int passwordStrength(String password) {
    int lengthScore = 0;
    if (password.length < 8) {
      lengthScore = 0;
    } else if (password.length < 13) {
      lengthScore = 2;
    } else if (password.length < 19) {
      lengthScore = 4;
    } else {
      lengthScore = 6;
    }

    int varietyScore = 0;
    if (password.contains(RegExp(r'[a-zA-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      varietyScore = 6;
    } else if (password.contains(RegExp(r'[a-zA-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      varietyScore = 4;
    } else if (password.contains(RegExp(r'[a-zA-Z]'))) {
      varietyScore = 2;
    }

    int uniquenessScore = 0;
    if (password.contains(RegExp(r'\b\w+\b'))) {
      uniquenessScore = 4;
    } else {
      uniquenessScore = 2;
    }

    int totalScore = lengthScore + varietyScore + uniquenessScore;

    if (totalScore < 4) {
      return 0;
    } else if (totalScore < 7) {
      return 1;
    } else if (totalScore < 10) {
      return 2;
    } else if (totalScore < 13) {
      return 3;
    } else {
      return 4;
    }
  }

  List<Color> _passwordStrengthColors = [
    const Color.fromARGB(255, 206, 14, 14),
    const Color.fromARGB(255, 242, 116, 13),
    const Color.fromARGB(255, 240, 244, 19),
    const Color.fromARGB(255, 136, 227, 18),
    const Color.fromARGB(255, 39, 202, 15),
  ];
}

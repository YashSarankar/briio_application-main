import 'package:briio_application/screens/auth/sign_in.dart';
import 'package:briio_application/widgets/buttom_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/colors.dart';
import '../../utils/globel_veriable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';  // Make sure this import is at the top

class OTPVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final bool isRegistration;

  const OTPVerificationScreen({
    Key? key,
    required this.mobileNumber,
    this.isRegistration = false,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  // Add new controllers for individual OTP digits
  final List<TextEditingController> _otpDigitControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Add timer variables
  Timer? _countdownTimer;
  int _timeRemaining = 120; // 2 minutes in seconds
  
  @override
  void initState() {
    super.initState();
    startCountdownTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    for (var controller in _otpDigitControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Combine all digits into main controller
    _otpController.text = _otpDigitControllers
        .map((controller) => controller.text)
        .join();
  }

  void startCountdownTimer() {
    _countdownTimer?.cancel();
    _timeRemaining = 120; // Reset to 2 minutes instead of 10
    
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          timer.cancel();
          Fluttertoast.showToast(
            msg: 'OTP has expired. Please request a new one.',
            backgroundColor: Colors.red,
          );
        }
      });
    });
  }

  String formatTimeRemaining() {
    int minutes = _timeRemaining ~/ 60;
    int seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://briio.in/api/verify-login-otp'),
        body: {
          'mobile_no': widget.mobileNumber,
          'otp': _otpController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          // Save user data from the response
          if (data['data'] != null) {
            final userData = data['data'];
            
            // Save to SharedPreferences first
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userData', json.encode(userData));
            
            // Then update GlobalK
            GlobalK.userId = userData['id'];
            GlobalK.userFName = userData['name'];
            GlobalK.userEmail = userData['email'];
            GlobalK.phone = userData['phone'];
            GlobalK.companyName = userData['company_name'];
            GlobalK.gst = userData['gst_number'];
            GlobalK.hallMarks = userData['holemarks_license'];
            GlobalK.address = userData['address'] ?? 'Not Updated';
            GlobalK.city = userData['city'] ?? 'Not Updated';
            GlobalK.state = userData['state'] ?? 'Not Updated';
            GlobalK.pincode = userData['pincode'] ?? 'Not Updated';
          }
          
          Fluttertoast.showToast(msg: data['message'] ?? 'Successfully verified');
          
          // Navigate to home screen and clear all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage5()),
            (route) => false,
          );
        } else {
          Fluttertoast.showToast(msg: data['message'] ?? 'Invalid OTP');
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Clear GlobalK values
      GlobalK.userId = null;
      GlobalK.userFName = null;
      GlobalK.userEmail = null;
      GlobalK.phone = null;
      GlobalK.companyName = null;
      GlobalK.gst = null;
      GlobalK.hallMarks = null;
      GlobalK.address = null;
      GlobalK.city = null;
      GlobalK.state = null;
      GlobalK.pincode = null;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignIn()),
        (route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> _resendOTP() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('https://briio.in/api/login-via-otp'),
        body: {
          'mobile_no': widget.mobileNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          Fluttertoast.showToast(
            msg: data['message'] ?? 'OTP sent successfully',
            backgroundColor: Colors.green,
          );
          
          // Clear existing OTP fields
          for (var controller in _otpDigitControllers) {
            controller.clear();
          }
          _otpController.clear();
          
          // Focus on first field
          _focusNodes[0].requestFocus();
          
          // Restart the timer
          startCountdownTimer();
        } else {
          Fluttertoast.showToast(
            msg: data['message'] ?? 'Failed to send OTP',
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to send OTP. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('Resend OTP Error: $e');
      Fluttertoast.showToast(
        msg: 'Error: Failed to resend OTP',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add this getter to check if resend is allowed
  bool get canResendOTP => _timeRemaining == 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.logo2, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.logo2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    size: 40,
                    color: AppColors.logo2,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Enter the verification code we just sent to\n',
                      ),
                      TextSpan(
                        text: '+91 ${widget.mobileNumber}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => Container(
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _otpDigitControllers[index],
                        focusNode: _focusNodes[index],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColors.logo2, width: 2),
                          ),
                        ),
                        onChanged: (value) => _onOtpDigitChanged(value, index),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.logo2,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.logo2.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logo2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Verify & Proceed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: (_isLoading || !canResendOTP) ? null : _resendOTP,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        disabledForegroundColor: Colors.grey[400],
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.logo2,
                              ),
                            )
                          : Text(
                              'Resend',
                              style: TextStyle(
                                color: canResendOTP ? AppColors.logo2 : Colors.grey[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: _timeRemaining < 60 ? Colors.red[400] : Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Code expires in ${formatTimeRemaining()}',
                          style: TextStyle(
                            color: _timeRemaining < 60 
                                ? Colors.red[400] 
                                : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: _timeRemaining < 60 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
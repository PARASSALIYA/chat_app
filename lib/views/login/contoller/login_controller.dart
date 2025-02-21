import 'package:chat_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../../../model/user.model.dart';
import '../../../services/firestore_services.dart';
import '../../../uitlls/get_pages.dart';

class LoginController extends GetxController {
  RxBool isPasswordVisible = true.obs;

  void changePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login(email, password) async {
    String msg = await AuthServices.authServices.login(email, password);
    if (msg == "Success") {
      toastification.show(
        title: const Text("Success"),
        description: const Text("Login successfully"),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
      );
      Get.offNamed(GetPages.home);
      // Get.offNamed(GetPages.otpVerification);
    } else {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 2),
        title: const Text("Error"),
        description: Text(msg),
        type: ToastificationType.error,
      );
    }
  }

  Future<void> loginWithGoogle() async {
    String msg = await AuthServices.authServices.signUpWithGoogle();
    if (msg == "Success") {
      Get.offNamed(GetPages.home);
      // Get.offNamed(GetPages.otpVerification);
      var user = AuthServices.authServices.currentUser;

      if (user != null) {
        FirestoreServices.firestoreServices.addUser(
          model: UserModel(
              uid: user.uid ?? "",
              name: user.displayName ?? "",
              email: user.email ?? "",
              password: "",
              selectedImage: "",
              image: user.photoURL ?? "",
              token: await FirebaseMessaging.instance.getToken() ?? "",
              cNumber: user.phoneNumber ?? ""),
        );
        AuthServices.authServices.sendVerificationEmail();
      }
    }
  }

  void loginWithAnonymous() async {
    User? user = await AuthServices.authServices.anonymousLogin();
    if (user != null) {
      toastification.show(
        title: const Text("Success"),
        description: const Text("Login successfully"),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
      );
      Get.offNamed(GetPages.otpVerification);
    }
  }

  Future<void> currentUser() async {
    User? user = AuthServices.authServices.currentUser!;
    if (user != null) {
      toastification.show(
        title: const Text("Success"),
        description: const Text("Login successfully"),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
      );
      Get.offNamed(GetPages.home);
    } else {}
  }

  void signOut() {
    AuthServices.authServices.signOut();
    Get.offNamed(GetPages.login);
  }
}

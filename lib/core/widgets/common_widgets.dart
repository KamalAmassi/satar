import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/data/backend.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';

Backend get backend => Get.find<Backend>();
CartController get cartCtl => Get.find<CartController>();

String failureText(Failure f) => FailureMessages.localizedMessage(Get.context!, f);

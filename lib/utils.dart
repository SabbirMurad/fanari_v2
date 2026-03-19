library utils;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:fanari_v2/app.dart';
import 'package:fanari_v2/routes.dart';
import 'package:fanari_v2/utils/print_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fanari_v2/constants/local_storage.dart';


part './utils/validation.dart';
part './utils/rich_text.dart';
part './utils/data_types/string.dart';
part './utils/data_types/int.dart';
part './utils/short_name.dart';
part './utils/custom_http.dart';
part './utils/pretty_date.dart';
part './utils/custom_toast.dart';
part './utils/number_magnitude.dart';
part './utils/check_for_internet.dart';
part './utils/simple_text_updater.dart';
part './utils/report_widget.dart';
part './utils/ffmpeg.dart';

int randomNumber(int min, int max) => min + Random().nextInt(max - min);

library utils;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:fanari_v2/constants/colors.dart';
import 'package:fanari_v2/app.dart';
import 'package:fanari_v2/widgets/custom_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:fanari_v2/constants/credential.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' as img;


part './utils/image_blur_hash.dart';
part './utils/rich_text.dart';
part './utils/data_types/string.dart';
part './utils/data_types/int.dart';
part './utils/short_name.dart';
part './utils/custom_http.dart';
part './utils/pretty_date.dart';
part './utils/custom_toast.dart';
part './utils/image_picker.dart';
part './utils/image_viewer.dart';
part './utils/video_picker.dart';
part './utils/audio_picker.dart';
part './utils/number_magnitude.dart';
part './utils/check_for_internet.dart';
part './utils/simple_text_updater.dart';
part './utils/report_widget.dart';
part './utils/ffmpeg.dart';

int randomNumber(int min, int max) => min + Random().nextInt(max - min);

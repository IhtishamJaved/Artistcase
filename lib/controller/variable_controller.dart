import 'package:get/get.dart';

class VariableController extends GetxController {
  ///Story Upload Variable/////
  var isUpload = false.obs;
  var picIsUploading = false.obs;

  ///post Uplaod Variable////////
  var postPisUploading = false.obs;
  var postVideoUploading = false.obs;
  var postMusicUploading = false.obs;

  ///Post Edit Variable/////
  var editpostPisUploading = false.obs;
  var editpostVideoUploading = false.obs;
  var editpostMusicUploading = false.obs;
}

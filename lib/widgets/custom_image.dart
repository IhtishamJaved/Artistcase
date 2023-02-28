import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constant/sizeconfig.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    imageBuilder: (context, imageProvider) => Container(
      height: SizeConfig.heightMultiplier * 27,
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 1 * SizeConfig.heightMultiplier,
        left: 3 * SizeConfig.widthMultiplier,
        right: 3 * SizeConfig.widthMultiplier,
        bottom: 1 * SizeConfig.heightMultiplier,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
    ),
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(60),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

Widget profilecachedNetworkImage(String mediaUr) {
  return CachedNetworkImage(
    imageUrl: mediaUr,
    fit: BoxFit.cover,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
          // color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    ),
    placeholder: (context, url) => Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.all(60),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

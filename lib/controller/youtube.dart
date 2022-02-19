import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:medsos_downloader/routers/routeName.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

// ignore: camel_case_types
class youtube extends GetxController {
  TextEditingController searchController = TextEditingController();
  var titles = "".obs;
  var authors = "".obs;
  var durations = "".obs;
  var thumbnails = "".obs;
  var time = 0.obs;
  var showingDetails = false.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final FlutterFFmpegConfig _flutterFFmpegConfig = new FlutterFFmpegConfig();
    _flutterFFmpegConfig.enableStatisticsCallback(statisticsCallback);
    initializeDownloader();
    permissionNotifpush();
  }

  getDetail() async {
    showingDetails.value = true;
    var yt = YoutubeExplode();
    var video = await yt.videos.get(searchController.text);
    titles.value = video.title;
    authors.value = video.author;
    durations.value = video.duration.toString();
    time.value = video.duration!.inSeconds;
    thumbnails.value = video.thumbnails.highResUrl;
  }

  void initializeDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
  }

  download(context, RoundedLoadingButtonController controller) async {
    Timer(Duration(seconds: 10), () {
      controller.reset();
    });
    var yt = YoutubeExplode();
    var id = VideoId(searchController.text.trim());
    var video = await yt.videos.get(id);
    await Permission.storage.request();

    // Get the streams manifest and the audio track.
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.first;

    // Build the directory.
    var dir = await DownloadsPathProvider.downloadsDirectory;
    var filePath = path.join(
        dir!.uri.toFilePath(), '${video.title}.${audio.container.name}');

    filePath = filePath.replaceAll(' ', '');
    filePath = filePath.replaceAll("'", '');
    filePath = filePath.replaceAll('"', '');
    print(filePath);

    // Open the file to write.
    var file = File(filePath);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into our file.
    await yt.videos.streamsClient.get(audio).pipe(fileStream);
    /*
                  If you want to show a % of download, you should listen
                  to the stream instead of using `pipe` and compare
                  the current downloaded streams to the totalBytes,
                  see an example ii example/video_download.dart
                   */

    // Close the file.

    var len = audio.size.totalBytes;
    var count = 0;

    print("starting convertion");
    var arguments = [];
    if (filePath.endsWith('.mp4')) {
      arguments = ["-i", filePath, filePath.replaceAll('.mp4', '.mp3')];
    } else if (filePath.endsWith('.webm')) {
      arguments = ["-i", filePath, filePath.replaceAll('.webm', '.mp3')];
    } else if (filePath.endsWith('.mp3')) {
      print('Already .mp3');
      return true;
    } else {
      print('Unknown format to convert.');
      return false;
    }

    var _flutterFFmpeg = new FlutterFFmpeg();
    await _flutterFFmpeg
        .executeWithArguments(arguments)
        .then((rc) => print("FFmpeg process exited with rc $rc"));

    //delete webm format
    if (filePath.endsWith('.webm') || filePath.endsWith('.mp4')) {
      file.delete();
    }

    print("Everything is fine!");

    await fileStream.flush();
    await fileStream.close();

    // Show that the file was downloaded.
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
              'Download berhasil tersimpan di: ${filePath.replaceAll(".mp4", ".mp3")}'),
        );
      },
    );
  }

  downloadmp4(context, RoundedLoadingButtonController controller) async {
    Timer(Duration(seconds: 10), () {
      controller.reset();
    });
    var yt = YoutubeExplode();
    var id = VideoId(searchController.text.trim());
    var video = await yt.videos.get(id);
    await Permission.storage.request();

    // Get the streams manifest and the audio track.
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.first;
    var videos = manifest.videoOnly.first;

    // Build the directory.
    var dir = await DownloadsPathProvider.downloadsDirectory;
    var filePath = path.join(
        dir!.uri.toFilePath(), '${video.title}-audio.${audio.container.name}');

    var filePath2 = path.join(
        dir.uri.toFilePath(), '${video.title}-video.${videos.container.name}');
    var filePath3 = path.join(
        dir.uri.toFilePath(), '${video.title}.${videos.container.name}');

    filePath = filePath.replaceAll(' ', '');
    filePath = filePath.replaceAll("'", '');
    filePath = filePath.replaceAll('"', '');
    print(filePath);
    filePath2 = filePath2.replaceAll(' ', '');
    filePath2 = filePath2.replaceAll("'", '');
    filePath2 = filePath2.replaceAll('"', '');
    print(filePath2);

    filePath3 = filePath3.replaceAll(' ', '');
    filePath3 = filePath3.replaceAll("'", '');
    filePath3 = filePath3.replaceAll('"', '');
    print(filePath3);

    // Open the file to write.
    var file = File(filePath);
    var fileStream = file.openWrite();

    var file2 = File(filePath2);
    var fileStream2 = file2.openWrite();

    var file3 = File(filePath3);
    var fileStream3 = file3.openWrite();

    // Pipe all the content of the stream into our file.
    await yt.videos.streamsClient.get(audio).pipe(fileStream);
    await yt.videos.streamsClient.get(videos).pipe(fileStream2);
    /*
                  If you want to show a % of download, you should listen
                  to the stream instead of using `pipe` and compare
                  the current downloaded streams to the totalBytes,
                  see an example ii example/video_download.dart
                   */

    // Close the file.

    var len = audio.size.totalBytes;
    var count = 0;

    var _flutterFFmpeg = new FlutterFFmpeg();

    await _flutterFFmpeg
        .execute("-y -i $filePath2 -i $filePath -c copy $filePath3")
        .then((return_code) => print("Return code $return_code"));

    if (filePath.endsWith('.mp4') || filePath.endsWith('.webm')) {
      file.delete();
    }
    if (filePath2.endsWith('.mp4') || filePath2.endsWith('.webm')) {
      file2.delete();
    }
    print("Everything is fine!");
    await fileStream.flush();
    await fileStream2.flush();
    await fileStream2.close();
    await fileStream.close();

    // Show that the file was downloaded.
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Download berhasil tersimpan di: $filePath3'),
        );
      },
    );
  }

  void statisticsCallback(x) async {
    double percentage = ((x.time / 1000) / time.value) * 100;
    debugPrint('progress = ${percentage.toStringAsFixed(0)} %');
    // progress = [0 - 100] %
    if (percentage.round() != 100) {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: titles.value,
              body: '${percentage.toStringAsFixed(0)}%',
              notificationLayout: NotificationLayout.ProgressBar,
              progress: percentage.round(),
              locked: true));
    } else {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: titles.value,
              body: "Download Sukses",
              locked: false));
    }
  }

  permissionNotifpush() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }
}

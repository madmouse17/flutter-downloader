import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medsos_downloader/controller/youtube.dart';
import 'package:medsos_downloader/view/constant.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnControllermp4 =
      RoundedLoadingButtonController();
  final yt = Get.put(youtube());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.grey,
                child: Stack(
                  children: [
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.08,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(80),
                                topRight: Radius.circular(80)),
                            color: redYT),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(children: [
                                Text("Download Youtube",
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                ),
                                TextField(
                                  controller: yt.searchController,
                                  decoration: InputDecoration(
                                      hintText: "Paste Link in here",
                                      fillColor: Colors.white,
                                      filled: true,
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            yt.getDetail();
                                          },
                                          icon: Icon(Icons
                                              .youtube_searched_for_rounded))),
                                ),
                                if (yt.showingDetails.value == true) ...[
                                  Obx(
                                    () => Container(
                                      width: 300,
                                      height: 232,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  "${yt.thumbnails}"))),
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      yt.titles.value,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      yt.authors.value,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      yt.durations.value,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: RoundedLoadingButton(
                                      color: Colors.amber[400],
                                      successColor: Colors.amber,
                                      width: 150,
                                      controller: _btnController,
                                      onPressed: () {
                                        yt.download(context, _btnController);
                                      },
                                      valueColor: Colors.white,
                                      borderRadius: 10,
                                      child: Text(
                                        "Download Mp3",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  RoundedLoadingButton(
                                    color: Colors.blue,
                                    width: 150,
                                    successColor: Colors.blue,
                                    controller: _btnControllermp4,
                                    onPressed: () {
                                      yt.downloadmp4(
                                          context, _btnControllermp4);
                                    },
                                    valueColor: Colors.white,
                                    borderRadius: 10,
                                    child: Text(
                                      "Download Mp4",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ]),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

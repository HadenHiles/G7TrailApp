import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/models/firestore/destination_art.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:g7trailapp/utility/fullscreen_image.dart';
import 'package:provider/provider.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/services/network_status_service.dart';
import 'package:g7trailapp/widgets/screen_title.dart';

class ArtScreen extends StatefulWidget {
  const ArtScreen({Key? key, required this.art}) : super(key: key);

  final DestinationArt? art;

  @override
  _ArtScreenState createState() => _ArtScreenState();
}

class _ArtScreenState extends State<ArtScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<NetworkStatus>(
      create: (context) {
        return NetworkStatusService().networkStatusController.stream;
      },
      initialData: NetworkStatus.Online,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                collapsedHeight: 65,
                expandedHeight: 65,
                floating: true,
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      size: 28,
                    ),
                    onPressed: () {
                      navigatorKey.currentState!.pop();
                    },
                  ),
                ),
                flexibleSpace: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: FlexibleSpaceBar(
                    collapseMode: CollapseMode.none,
                    titlePadding: EdgeInsets.only(top: 25, left: 50),
                    centerTitle: false,
                    title: ScreenTitle(title: widget.art!.title, maxWidth: MediaQuery.of(context).size.width - 75),
                    background: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
                actions: const [],
              ),
            ];
          },
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: loadFirestoreImage(widget.art!.image, null),
                builder: (context, snap) {
                  String imgUrl = snap.data.toString();

                  return !snap.hasData
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(50),
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : ImageFullScreenWrapperWidget(
                          child: CachedNetworkImage(
                            imageUrl: imgUrl,
                            placeholder: (context, _) {
                              return SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                child: Text(
                  widget.art!.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

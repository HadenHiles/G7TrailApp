import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:g7trailapp/widgets/basic_title.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            collapsedHeight: 65,
            expandedHeight: 100,
            backgroundColor: Theme.of(context).colorScheme.primary,
            iconTheme: Theme.of(context).iconTheme,
            actionsIconTheme: Theme.of(context).iconTheme,
            floating: true,
            pinned: true,
            flexibleSpace: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              child: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                titlePadding: null,
                centerTitle: false,
                title: BasicTitle(title: "Explore"),
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            actions: null,
          ),
        ];
      },
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 15, right: 0, bottom: 15, left: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      "Easy".toUpperCase(),
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 310,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildDestination(
                            Text(
                              "Pic Island".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/pic-island-example.jpeg"),
                            ),
                            Text("Easy", style: Theme.of(context).textTheme.bodyText1),
                          ),
                          _buildDestination(
                            Text(
                              "Painters Peak".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/painters-peak-example.jpg"),
                            ),
                            Text("Easy", style: Theme.of(context).textTheme.bodyText1),
                          ),
                          _buildDestination(
                            Text(
                              "Peninsula Harbour".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/peninsula-harbour-example.jpeg"),
                            ),
                            Text("Easy", style: Theme.of(context).textTheme.bodyText1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 15),
                      child: Divider(
                        color: darken(Theme.of(context).colorScheme.background, 0.25),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Moderate".toUpperCase(),
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 310,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildDestination(
                            Text(
                              "Pic Island".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/pic-island-example.jpeg"),
                            ),
                            Text("Moderate", style: Theme.of(context).textTheme.bodyText1),
                          ),
                          _buildDestination(
                            Text(
                              "Painters Peak".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/painters-peak-example.jpg"),
                            ),
                            Text("Moderate", style: Theme.of(context).textTheme.bodyText1),
                          ),
                          _buildDestination(
                            Text(
                              "Peninsula Harbour".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/peninsula-harbour-example.jpeg"),
                            ),
                            Text("Moderate", style: Theme.of(context).textTheme.bodyText1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 15),
                      child: Divider(
                        color: darken(Theme.of(context).colorScheme.background, 0.25),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Difficult".toUpperCase(),
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 310,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildDestination(
                            Text(
                              "Pic Island".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/pic-island-example.jpeg"),
                            ),
                            Text("Difficult", style: Theme.of(context).textTheme.bodyText1),
                          ),
                          _buildDestination(
                            Text(
                              "Painters Peak".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/painters-peak-example.jpg"),
                            ),
                            Text("Difficult", style: Theme.of(context).textTheme.bodyText1),
                          ),
                          _buildDestination(
                            Text(
                              "Peninsula Harbour".toUpperCase(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Image(
                              image: AssetImage("assets/images/destinations/peninsula-harbour-example.jpeg"),
                            ),
                            Text("Difficult", style: Theme.of(context).textTheme.bodyText1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestination(Widget title, Image image, Widget trailing) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: (MediaQuery.of(context).size.width * 0.8) * .73,
                child: FittedBox(
                  clipBehavior: Clip.antiAlias,
                  fit: BoxFit.cover,
                  child: image,
                ),
              ),
            ),
            ListTile(
              title: title,
              trailing: trailing,
            ),
          ],
        ),
        color: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0,
        margin: EdgeInsets.only(right: 10, top: 10),
      ),
    );
  }
}

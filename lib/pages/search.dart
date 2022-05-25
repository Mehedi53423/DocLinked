import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doclinked1/models/user.dart';
import 'package:doclinked1/pages/activity_feed.dart';
import 'package:doclinked1/pages/home.dart';
import 'package:doclinked1/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query){
    Future<QuerySnapshot> users = usersRef.where("displayName", isGreaterThanOrEqualTo: query).getDocuments();

    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch(){
    searchController.clear();
  }

  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for user",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            //SvgPicture.asset(
              //'assets/images/search.svg',
              //height: orientation == Orientation.portrait ? 300.0 : 200.0,
            //),
            Image(
              image: AssetImage("assets/images/neo-sakura-searching.png"),
              //height: orientation == Orientation.portrait ? 450.0 : 300.0,
            ),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  "Find Users",
                  cursor: "",
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    fontSize: 60.0,
                    fontFamily: "Signatra",
                    color: Colors.white,
                  ),
                  speed: const Duration(milliseconds: 200),
                ),
              ],

              //totalRepeatCount: 4,
              pause: const Duration(milliseconds: 500),
              //displayFullTextOnTap: true,
              //stopPauseOnTap: true,
              repeatForever: true,
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults(){
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}

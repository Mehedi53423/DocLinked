import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doclinked1/models/user.dart';
import 'package:doclinked1/pages/edit_profile.dart';
import 'package:doclinked1/pages/home.dart';
import 'package:doclinked1/widgets/post.dart';
import 'package:doclinked1/widgets/post_tile.dart';
import 'package:doclinked1/widgets/progress.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  String postOrientation = "grid";
  bool isLoading = false;
  bool isFollowing = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];



  @override
  void initState(){
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async{
    DocumentSnapshot doc = await followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async{
    QuerySnapshot snapshot = await followersRef.document(widget.profileId).collection('userFollowers').getDocuments();

    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async{
    QuerySnapshot snapshot = await followingRef.document(widget.profileId).collection('userFollowing').getDocuments();

    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef.document(widget.profileId).collection('userPosts').orderBy('timestamp', descending: true).getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}){
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: TextButton(
        onPressed: function,
        child: Container(
          width: 245.0,
          height: 26.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton(){
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    }
    else if(isFollowing){
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    }
    else if(!isFollowing){
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser(){
    setState(() {
      isFollowing = false;
    });
    followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
    followingRef.document(currentUserId).collection('userFollowing').document(widget.profileId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
    activityFeedRef.document(widget.profileId).collection('feedItems').document(currentUserId).get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  handleFollowUser(){
    setState(() {
      isFollowing = true;
    });
    followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).setData({});
    followingRef.document(currentUserId).collection('userFollowing').document(widget.profileId).setData({});
    activityFeedRef.document(widget.profileId).collection('feedItems').document(currentUserId).setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildProfileHeader(){
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 2.0, 0, 12.0),
                child: Text(
                  user.bio,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              Row(
                children: <Widget>[

                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn(
                                "Posts",
                                postCount,
                            ),
                            Container(
                              width: 1.0,
                              height: 40.0,
                              color: Colors.grey,
                            ),
                            buildCountColumn(
                              "Followers",
                              followerCount,
                            ),
                            Container(
                              width: 1.0,
                              height: 40.0,
                              color: Colors.grey,
                            ),
                            buildCountColumn(
                              "Following",
                              followingCount,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts(){
    if(isLoading){
      return circularProgress();
    }
    else if(posts.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //SvgPicture.asset('assets/images/no_content.svg', height: 260.0,),
            Image(
              image: AssetImage("assets/images/neo-sakura-fatal-error.png"),
              //height: 250.0,
            ),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  "No Posts",
                  cursor: "",
                  textStyle: const TextStyle(
                    fontSize: 50.0,
                    fontFamily: "Signatra",
                    color: Colors.redAccent,
                  ),
                  speed: const Duration(milliseconds: 200),
                ),
              ],
              //totalRepeatCount: 4,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: false,
              stopPauseOnTap: false,
              repeatForever: true,
            ),
          ],
        ),
      );
    }
    else if(postOrientation == "grid"){
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(
          GridTile(
              child: PostTile(post)
          ),
        );
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    else if(postOrientation == "list"){
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation){
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid" ? Colors.white : Colors.grey,
        ),
        Container(
          width: 1.0,
          height: 40.0,
          color: Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list" ? Colors.white : Colors.grey,
        ),
      ],
    );
  }

  logout() async{
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    bool isProfileOwner = currentUserId == widget.profileId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
            "Profile",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: isProfileOwner ? <Widget>[
          IconButton(
            tooltip: 'Log Out',
            onPressed: logout,
            icon: Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
          ),
        ] : null,
      ),

      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(
            color: Colors.grey,
          ),
          buildTogglePostOrientation(),
          Divider(
            color: Colors.grey,
            //height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
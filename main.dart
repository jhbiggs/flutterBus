// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(FlutterBus());

//extend stateless widget as required to run app

class FlutterBus extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check-In',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: RandomWords(),
    );
  }
  // #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var
class RandomWordsState extends State<RandomWords> {
  Future<Post> post;
  final _suggestions = <String>[];
  final Set<String> _saved = Set<String>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    post = fetchPost();

  }
  final names = ['joe', 'bob','billy', 'moe', 'larry', 'curly','jackson', 
    'jethro', 'caitlyn', 'mary', 'donna', 'justin', 'ella', 'fraser', 'charlie'];




  // #docregion _buildNames
  Widget _buildNames() {
    names.sort();
    var rows = names.map((name) => _buildRow(name)).toList();
    return ListView(
        padding: const EdgeInsets.all(16.0),
        children: rows,
        );
        }
  // #enddocregion _buildNames

  // #docregion _buildRow
  Widget _buildRow(String name) {
    final bool alreadySaved = _saved.contains(name);
    return ListTile(
      title: Text(
        name,
        style: _biggerFont,
      ),
      leading: Image.asset("test.jpg", fit: BoxFit.scaleDown),
      trailing: Icon(alreadySaved ? Icons.check_box :Icons.check_box_outline_blank),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(name);
          } else {
            _saved.add(name);
            _suggestions.remove(name);
          }
        });
      },
    );
  }
  // #enddocregion _buildRow

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-In'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          IconButton(icon: Icon(Icons.settings), onPressed: _pushSettings),
        ],
      ),
      body: _buildNames
  (),
    );
  }
// #enddocregion RWS-build


  void _pushSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context){

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
            
             return Scaffold (

            appBar: AppBar(title: Text('Settings')),
            body: Center (
              child: FutureBuilder<Post>(
                  future: post,
                  builder: (context, snapshot) {

                    if (snapshot.hasData) {
                    final bool isConnected = snapshot.hasData;
                      return Container (                
                        child: ListView (
                        padding: const EdgeInsets.all(16.0),
                        children: <Widget> [
                            Text(snapshot.data.title),
                            Divider(height: 5.0),

                            Text(snapshot.data.body),
                            Divider(height: 5.0),

                            Text("UserID is: ${snapshot.data.userId}"),
                            Divider(height: 5.0),

                            Text("ID is: ${snapshot.data.id}"),
                            Divider(height: 5.0),

                            ListTile (
                            title: Text("Has Data", style: TextStyle(fontSize: 18.0),), 
                            trailing: Icon(isConnected ? Icons.check_box : Icons.check_box_outline_blank),
                            
                            ),
                            Divider(height: 5.0),

                          ],
                        )
                        );
                     
                      } else if (snapshot.hasError) {
                      return Text("Your error is:...${snapshot.error}");
                      } 
                      return CircularProgressIndicator();
                    
                    },
                 )
                ),
              );
            },
          );
        },
      )
    );
  }


  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          final Iterable<ListTile> tiles = _saved.map(
            (String name) {
              return ListTile(
                title: Text(
                  name,
                  style: TextStyle(fontSize: 36.0),
                ),
                trailing: Icon(Icons.delete),
                onTap: () {
                  setState (() {
                   _saved.remove(name);
                     
                  });
                }
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('All Checked In'),
            ),
            body: ListView(children: divided),
          );
          }
          );
        },
      ),
    );
  }


// #docregion FuturePost

  Future<Post> fetchPost() async {
    final response = await http.get('https://jsonplaceholder.typicode.com/posts/3');

    if (response.statusCode == 200) {
    //if server responds "OK", parse the JSON
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception ('failed to load post');
    }
  }
  // #enddocregion Future fetchPost
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
  }

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}
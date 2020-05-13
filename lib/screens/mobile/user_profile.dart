import 'dart:async';

import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:github_activity_feed/app/provided.dart';
import 'package:github_activity_feed/services/extensions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserProfile extends StatefulWidget {
  final User currentUser;

  const UserProfile({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with ProvidedState {
  User _currentUser;
  StreamSubscription<User> _userSub;

  @override
  void initState() {
    super.initState();
    _userSub = github.github.users
        .getUser(widget.currentUser.login)
        .asStream()
        .listen((User u) => setState(() => _currentUser = u));
  }

  @override
  void dispose() {
    _userSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.subtitle1,
      child: Column(
        children: [
          if (_currentUser?.bio != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  title: Text(_currentUser?.bio),
                ),
              ),
            ),
          if (_currentUser?.location != null)
            ListTile(
              leading: Icon(MdiIcons.mapMarkerOutline),
              title: Text(_currentUser?.location),
            ),
          if (_currentUser?.blog != null)
            ListTile(
              leading: Icon(MdiIcons.link),
              title: Text(_currentUser?.blog),
            ),
          if (_currentUser?.createdAt != null)
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(_currentUser?.createdAt?.asMonthDayYear),
            ),
          Divider(height: 0),
          _ProfileEntry(
            name: 'Repositories',
            count: _currentUser?.login == user.login
                ? user.publicReposCount + user.privateReposCount
                : _currentUser?.publicReposCount,
          ),
          if (_currentUser?.login != user.login)
            _ProfileEntry(
              name: 'Following',
              count: _currentUser?.followingCount,
            ),
          _ProfileEntry(
            name: 'Followers',
            count: _currentUser?.followersCount,
          ),
          // todo: starred repo count?
          // todo: organizations count?
        ],
      ),
    );
  }
}

class _ProfileEntry extends StatelessWidget {
  final String name;
  final int count;

  const _ProfileEntry({
    Key key,
    this.name,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text('$count'),
        ],
      ),
    );
  }
}
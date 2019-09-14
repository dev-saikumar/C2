import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SharedPreferencesBuilder<T> extends StatelessWidget {
	final String pref;
	final AsyncWidgetBuilder<T> builder;
	
	const SharedPreferencesBuilder({
		Key key,
		@required this.pref,
		@required this.builder,
	}) : super(key: key);
	
	@override
	Widget build(BuildContext context) {
		return FutureBuilder<T>(
			future: _future(),
			builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
				return this.builder(context, snapshot);
			});
	}
	
	Future<T> _future() async {
		return (await SharedPreferences.getInstance()).get(pref);
	}
}
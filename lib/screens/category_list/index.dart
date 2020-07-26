import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<ItemDatabaseBloc>(context);
    if (bloc.state['allCategories'] is! AllCategoriesFetchedState) {
      bloc.add(FetchAllCategories());
    }
    return SafeArea(
      child: Scaffold(
          appBar: MyAppBar(
            hasTransparentBackground: true,
            title: L10n().getStr('home.shopByCategory'),
          ),
          body: Container(
              margin: EdgeInsets.only(top: Spacing.space12),
              child: Expanded(child: CategoryBody()))),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  final List listing;
  CategoryGrid({@required this.listing});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GridView.builder(
      scrollDirection: Axis.vertical,
      itemCount: listing.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        var item = listing[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                context,
                Constants.CATEGORY_LISTING
                    .replaceAll(':categoryId', item['id'].toString())
                    .replaceAll(':categoryName', item['name']));
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: Spacing.space12, vertical: Spacing.space8),
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(
                      'assets/images/' + item['id'].toString() + '.jpeg')),
            ),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white.withOpacity(0.6),
              padding: EdgeInsets.symmetric(horizontal: Spacing.space4),
              child: Center(
                  child: Text(
                item['name'],
                textAlign: TextAlign.center,
                style: theme.textTheme.body1Bold
                    .copyWith(color: ColorShades.bastille),
              )),
            ),
          ),
        );
      },
    );
  }
}

class CategoryBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: Spacing.space12),
      color: ColorShades.white,
      child: BlocBuilder<ItemDatabaseBloc, Map>(builder: (context, state) {
        var currentState = state['allCategories'];
        if (currentState is GlobalFetchingState) {
          return PageFetchingViewWithLightBg();
        } else if (currentState is GlobalErrorState) {
          return PageErrorView();
        } else if (currentState is AllCategoriesFetchedState) {
          var listing = currentState.categories;
          return CategoryGrid(
            listing: listing,
          );
        }
        return Container();
      }),
    );
  }
}

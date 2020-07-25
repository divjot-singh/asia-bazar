import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/item_cart.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_indicators/progress_indicators.dart';

class HomeView extends StatefulWidget {
  final bool isFetching;
  HomeView({this.isFetching = false});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemDatabaseBloc, Map>(builder: (context, state) {
      var currentState = state['homeItems'];
      if (currentState is GlobalFetchingState) {
        return PageFetchingViewWithLightBg();
      } else if (currentState is GlobalErrorState) {
        return PageErrorView();
      } else if (currentState is HomeItemsFetched) {
        var data = currentState.data;
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ...data.values.map((categoryList) {
                return CategoryTile(
                  items: categoryList,
                );
              }).toList(),
              if (widget.isFetching)
                Padding(
                  padding: EdgeInsets.only(bottom: Spacing.space12),
                  child: ScalingText(L10n().getStr('app.loading'),
                      style: Theme.of(context)
                          .textTheme
                          .h3
                          .copyWith(color: ColorShades.greenBg)),
                ),
            ],
          ),
        );
      }
      return Container();
    });
  }
}

class CategoryTile extends StatelessWidget {
  final List items;
  CategoryTile({this.items});
  @override
  Widget build(BuildContext context) {
    if (items.length == 0) return Container();
    ThemeData theme = Theme.of(context);
    var categoryName = items[0].data['dept_name'];
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.space8),
      decoration: BoxDecoration(
          color: ColorShades.white, boxShadow: [Shadows.cardLight]),
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.space16, vertical: Spacing.space12),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  categoryName,
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.bastille),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context,
                      Constants.CATEGORY_LISTING
                          .replaceAll(":categoryName", categoryName)
                          .replaceAll(":categoryId",
                              items[0].data['categoryId'].toString()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      L10n().getStr('editProfile.more'),
                      style: theme.textTheme.body2Regular
                          .copyWith(color: ColorShades.neon),
                    ),
                    SizedBox(
                      width: Spacing.space8,
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: 16,
                      color: ColorShades.neon,
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: Spacing.space16,
          ),
          Container(
            height: 180,
            child: ItemCarousel(
              items: items,
            ),
          )
        ],
      ),
    );
  }
}

class ItemCarousel extends StatelessWidget {
  final List items;
  ItemCarousel({@required this.items});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index].data;
        return ItemCard(item: item);
      },
    );
  }
}

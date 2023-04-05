part of '../dashboard.dart';

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({Key? key}) : super(key: key);

  @override
  State<DashboardMobile> createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "Exit Application",
            ),
            content: const Text(
              "Are You Sure?",
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);

    final articleCubit = ArticlesCubit.cubit(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          drawer: Drawer(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 40),
                      ListTile(
                        leading: const Icon(
                          Icons.home,
                        ),
                        title: const Text('Home'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                        ),
                        title: const Text('Setting'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.info,
                        ),
                        title: const Text('About Us'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                          child: Icon(
                        Icons.facebook,
                        color: Colors.blue,
                      )),
                      SizedBox(
                        child: Icon(
                          FeatherIcons.twitter,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(
                          child: Icon(
                        FeatherIcons.youtube,
                        color: Colors.blue,
                      )),
                      SizedBox(
                        child: Icon(
                          FeatherIcons.instagram,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    // Space.y1!,
                    padding: const EdgeInsets.only(),
                    color: Colors.yellow,
                    child: Image.network(
                        'https://businessbhutan.bt/wp-content/uploads/2022/09/lo.png'),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Space.y!,
                              Text(
                                DateFormat('EEEE, dd MMM')
                                    .format(DateTime.now()),
                                style: AppText.l1!.copyWith(
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                        Space.xm!,
                      ],
                    ),
                  ),
                  Space.y1!,
                  CustomTextField(
                    controller: searchController,
                    hint: 'Search keyword...',
                    textInputType: TextInputType.text,
                    prefixIcon: IconButton(
                      splashRadius: AppDimensions.normalize(8),
                      onPressed: () {
                        if (searchController.text.isNotEmpty) {
                          articleCubit.fetch(
                            keyword: searchController.text.trim(),
                          );
                        }
                      },
                      icon: const Icon(Icons.search),
                    ),
                    onChangeFtn: (value) {
                      if (value == null || value.isEmpty) {
                        articleCubit.fetch();
                      }
                      return value;
                    },
                    isSuffixIcon: true,
                  ),
                  const CategoryTabs(),
                  Space.y1!,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Stories',
                        style: AppText.h3b,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                            context, '/top-stories',
                            arguments: {
                              'title': AppUtils.categories[context
                                  .read<CategoryProvider>()
                                  .categoryIndexGet],
                            }),
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: AppDimensions.normalize(7),
                        ),
                      )
                    ],
                  ),
                  BlocBuilder<TopHeadlinesCubit, TopHeadlinesState>(
                    builder: (context, state) {
                      if (state is TopHeadlinesLoading) {
                        return Column(
                          children: [
                            const LinearProgressIndicator(),
                            for (int i = 0; i < 3; i++)
                              const _ShimmerArticleCard(
                                isArticle: false,
                              )
                          ],
                        );
                      } else if (state is TopHeadlinesFailure) {
                        return Text(state.error!);
                      } else if (state is TopHeadlinesSuccess) {
                        List<News> recentNews = List.generate(
                            state.data!.length >= 3 ? 3 : state.data!.length,
                            (index) => state.data![index]!);

                        return Column(
                          children: recentNews
                              .map(
                                (news) => BottomAnimator(
                                  child: HeadlinesCard(
                                    news: news,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      } else {
                        return const Text('Something Went Wrong!');
                      }
                    },
                  ),
                  Space.y2!,
                  Text(
                    'Picks for you',
                    style: AppText.h3b,
                  ),
                  Space.y!,
                  Space.y1!,
                  BlocBuilder<ArticlesCubit, ArticlesState>(
                    builder: (context, state) {
                      if (state is ArticlesFetchLoading) {
                        return Column(
                          children: [
                            const LinearProgressIndicator(),
                            for (int i = 0; i < 3; i++)
                              const _ShimmerArticleCard(
                                isArticle: true,
                              ),
                          ],
                        );
                      } else if (state is ArticlesFetchFailed) {
                        return Text(state.message!);
                      } else if (state is ArticlesFetchSuccess) {
                        List<Article> recentNews = List.generate(
                            state.data!.length, (index) => state.data![index]);
                        return Column(
                          children: recentNews
                              .map(
                                (article) => BottomAnimator(
                                  child: ArticleCard(
                                    article: article,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      } else {
                        return const Center(
                          child: Text('Something Went Wrong!'),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

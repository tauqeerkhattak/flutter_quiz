import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final QuizTypes quizType;
  const SubCategoryScreen(
      {Key? key, required this.categoryId, required this.quizType})
      : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => SubCategoryScreen(
              categoryId: arguments['categoryId'],
              quizType: arguments['quizType'],
            ));
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  void getSubCategory() {
    Future.delayed(Duration.zero, () {
      context.read<SubCategoryCubit>().fetchSubCategory(
            widget.categoryId,
            context.read<UserDetailsCubit>().getUserId(),
          );
    });
  }

  @override
  void initState() {
    super.initState();
    getSubCategory();
  }

  Widget _buildBackButton() {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: 15.0, start: 20),
        child: CustomBackButton(
          iconColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSubCategory() {
    return BlocConsumer<SubCategoryCubit, SubCategoryState>(
        bloc: context.read<SubCategoryCubit>(),
        listener: (context, state) {
          if (state is SubCategoryFetchFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              //
              UiUtils.showAlreadyLoggedInDialog(
                context: context,
              );
            }
          }
        },
        builder: (context, state) {
          if (state is SubCategoryFetchInProgress ||
              state is SubCategoryInitial) {
            return Center(
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),
            );
          }
          if (state is SubCategoryFetchFailure) {
            return Center(
              child: ErrorContainer(
                showBackButton: false,
                errorMessageColor: Theme.of(context).primaryColor,
                showErrorImage: true,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage),
                ),
                onTapRetry: () {
                  getSubCategory();
                },
              ),
            );
          }
          final subCategoryList =
              (state as SubCategoryFetchSuccess).subcategoryList;
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * (0.085),
              ),
              child: ListView.builder(
                padding: EdgeInsets.only(
                  bottom: 50,
                ),
                shrinkWrap: true,
                itemCount: subCategoryList.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: 90,
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Theme.of(context).primaryColor),
                      child: ListTile(
                        onTap: () {
                          if (widget.quizType == QuizTypes.guessTheWord) {
                            Navigator.of(context)
                                .pushNamed(Routes.guessTheWord, arguments: {
                              "type": "subcategory",
                              "typeId": subCategoryList[index].id,
                              "isPlayed": subCategoryList[index].isPlayed,
                            });
                          } else if (widget.quizType == QuizTypes.funAndLearn) {
                            Navigator.of(context)
                                .pushNamed(Routes.funAndLearnTitle, arguments: {
                              "type": "subcategory",
                              "typeId": subCategoryList[index].id,
                            });
                          } else if (widget.quizType ==
                              QuizTypes.audioQuestions) {
                            //
                            Navigator.of(context)
                                .pushNamed(Routes.quiz, arguments: {
                              "numberOfPlayer": 1,
                              "quizType": QuizTypes.audioQuestions,
                              "subcategoryId": subCategoryList[index].id,
                              "isPlayed": subCategoryList[index].isPlayed,
                            });
                          } else if (widget.quizType == QuizTypes.mathMania) {
                            //
                            Navigator.of(context)
                                .pushNamed(Routes.quiz, arguments: {
                              "numberOfPlayer": 1,
                              "quizType": QuizTypes.mathMania,
                              "subcategoryId": subCategoryList[index].id,
                              "isPlayed": subCategoryList[index].isPlayed,
                            });
                          }
                        },
                        trailing: Icon(
                          Icons.navigate_next_outlined,
                          size: 40,
                          color: Theme.of(context).backgroundColor,
                        ),
                        title: Text(
                          subCategoryList[index].subcategoryName!,
                          style: TextStyle(
                              color: Theme.of(context).backgroundColor),
                        ),
                      ));
                },
              ),
            ),
          );
        });
  }

  Widget _buildBannerAd() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BannerAdContainer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Stack(
          children: [
            PageBackgroundGradientContainer(),
            _buildSubCategory(),
            _buildBackButton(),
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }
}

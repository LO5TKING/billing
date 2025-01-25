import 'package:flutter/material.dart';

import 'color_constants.dart';

class DesignConstants {
//Common

  static const double defaultAppbarHeight = 70;
  static const double squadsBottomBarHeight = 50;
  static const double appBarPadding = 15;
  static const double appBarTitleHeight = 260;
  static const double appBarImgHeight = 45;

  static const double iconSize = 20;
  static const double bottomMenuIconSize = 25;


  static const double moreIconSize = 40;

  static const double tabHeight = 67;
  static const double tabFontSize = 11.5;


  static const double cardHeight = 215;
  static const double cardWidth = 165;
  static const double cardMargin = 15;
  static const double cardPadding = 15;
  static const double cardRadius = 8;
  static const double cardSpacing = 13;

  //sized box spacing dimen
  static const double height10 = 10;

  //font size
  static const double fontSize8 = 8;
  static const double fontSize10 = 10;
  static const double fontSize11 = 11;
  static const double fontSize12 = 12;
  static const double fontSize13 = 13;
  static const double fontSize14 = 14;
  static const double fontSize15 = 15;
  static const double fontSize16 = 16;
  static const double fontSize17 = 17;
  static const double fontSize18 = 18;
  static const double fontSize19 = 19;
  static const double fontSize20 = 20;
  static const double fontSize22 = 22;
  static const double fontSize24 = 24;
  static const double fontSize26 = 26;
  static const double fontSize28 = 28;
  static const double fontSize30 = 30;
  static const double fontSize32 = 32;
  static const double fontSize35 = 35;
  static const double fontSize50 = 50;
  static const double fontSize90 = 90;
  static const double fontSize92 = 92;

  //card curve border radius
  static const double borderRadius5 = 5;
  static const double borderRadius8 = 8;
  static const double borderRadius10 = 10;
  static const double borderRadius12 = 12;
  static const double borderRadius15 = 15;
  static const double borderRadius18 = 18;
  static const double borderRadius20 = 20;


  //icons size
  static const double iconSize8 = 8;
  static const double iconSize10 = 10;
  static const double iconSize12 = 12;
  static const double iconSize15 = 15;
  static const double iconSize16 = 16;
  static const double iconSize18 = 18;
  static const double iconSize20 = 20;
  static const double iconSize22 = 22;
  static const double iconSize26 = 26;
  static const double iconSize28 = 28;
  static const double iconSize45 = 45;
  static const double teamSiz34 = 34;
  static const double iconSize84 = 84;
  static const double avatarSize72 = 72;


  //home items padding
  static const double verticalPaddingHome = 60;

  //moments padding
  static const double momentsTopPadding = 17;

  //match center card padding home page
  static const double matchCenterTBPadding = 19;
  static const double matchCenterLRPadding = 14;

  //button heights
  static const double mediumBtnHeight = 50;
  static const double smallBtnHeight = 30;

  static const double smallImgWH = 15;

  static const double margin = 15;
  static const double smallPadding = 5;
  static const double smallSpacing = 12;

  static const double padding11 = 11;
  static const double padding12 = 12;
  static const double padding15 = 15;
  static const double padding16 = 16;
  static const double padding17 = 17;
  static const double padding20 = 20;
  static const double padding25 = 25;
  static const double padding5 = 5;
  static const double padding4 = 4;
  static const double padding = 15;
  static const double padding10 = 10;
  static const double padding0 = 0;
  static const double padding40 = 40;
  static const double padding45 = 45;
  static const double padding3 = 3;
  static const double padding8 = 8;
  static const double padding30 = 30;
  static const double padding32 = 32;
  static const double padding35 = 35;
  static const double padding50 = 50;
  static const double padding60 = 60;
  static const double padding80 = 80;
  static const double padding90 = 90;
  static const double padding100 = 100;

  //filter switch
  static const double filterSwitchWidth = 40;
  static const double filterSwitchHeight = 21;
  static const double filterSwitchOuterRadius = 100;


  static const double topPadding = 12;
  static const double spacing = 15;
  static const double editTextheight = 40;
  static const double editTextRadius = 7;
  static const double editTextPadding = 13;
  static const double editTextSpace = 34;
  static const double editTextFontSize = 13.5;
  static const double defaultKycNewHeaderHeight = 58;
  static const double checkBoxSize = 20;
  static const double imageHeightSize300 = 300;
  static const double newsDetailHeight400 = 400;

  //SizedBox height and width constants
  static const double sizedBoxHeight20 = 20;
  static const double sizedBoxHeight30 = 30;

  //CircleAvatar Radius
  static const double circleAvatarRadius20 = 20;

  //BoxDecorationCircularRadius
  static const double boxDecorationRadius50 = 50;
  static const double boxDecorationRadius5 = 5;
  static const double boxDecorationRadius8 = 8;

  //OtpTextField Height
  static const double otpTextFieldHeight60 = 60;
  static const double height66 = 66;
  static const double height64 = 64;

  //aspect Ratio and Max lines for otp fields
  static const double aspectRationAndMaxLines1 = 1;

  //pageViewer Duration const
  static const double pageViewerDuration = 400;

  //Picture Dimensions
  static const double svgHeight40 = 40;
  static const double svgWidth110 = 110;
  static const double imgWidth100 = 100;

  //Common Double Values
  static const double double35 = 35;
  static const double double50 = 50;

  //Match Center Values
  static const double double360 = 380;
  static const double double9 = 9;
  static const double double55 = 55;
  static const double double60 = 60;
  static const double double24 = 24;




  //Jersey Height
  static const double jerseyHeight = 120;


  static BoxDecoration getCenterGradient(Color primaryColor,Color secondaryColor){
    return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [
              primaryColor,
              secondaryColor
          ],
        ),
    );
  }

  static List<BoxShadow> getCardShadow() {
    return [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 10,
        offset: Offset(0, -4),
        spreadRadius: 2,
      )
    ];
  }

  static List<BoxShadow> getNoShadow() {
    return [
      BoxShadow(
          color: Colors.transparent,
          offset: Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 0)
    ];
  }

  //end card

  static List<BoxShadow> setOnlyBottomShadow() {
    return [
      const BoxShadow(
          color: Colors.black,
          offset: Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0)
    ];
  }
  static List<BoxShadow> setOnlyTopShadow() {
    return [
      const BoxShadow(
          color: Colors.black,
          offset: Offset(4, 0),
          blurRadius: 12,
          spreadRadius: 0)
    ];
  }

// end tab

  //buttons

  static const double buttonHeight = 25;
  static const double buttonRadius = 7;
  static const double buttonPadding = 10;
  static const double buttonTextSize = 12;

  static TextStyle getButtonStyle() {
    return const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: "Roboto",
        fontStyle: FontStyle.normal,
        fontSize: buttonTextSize);
  }

// endbuttons

//bottomsheet
  static const double bottomSheetPadding = 13;
  static const double bottomSheetTopRadius = 25;
  static const double bottomSheetTopBottomSpacing = 24;
  static const double bottomSheetButtonHeight = 50;
  static const double bottomSheetButtonWidth = 360;

  // static TextStyle getBottomSheetHeading() {
  //   return const TextStyle(
  //       color: AppColors.appBarColor,
  //       fontWeight: FontWeight.w700,
  //       fontFamily: "Roboto",
  //       fontStyle: FontStyle.normal,
  //       fontSize: 15.0);
  // }

  static TextStyle getBottomSheetButtonTextStyle() {
    return const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: "Roboto",
        fontStyle: FontStyle.normal,
        fontSize: 12.5);
  }

//end bottomsheet

  //dialog
  static const double dialogPaddingRightLeft = 13;
  static const double dialogPaddingTopBottom = 24;
  static const double dialogRadius = 10;
  static const double dialogButtonHeight = 38;
  static const double dialogButtonRadius = 10;

  static TextStyle getDialogButtonTextStyle() {
    return const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: "Roboto",
        fontStyle: FontStyle.normal,
        fontSize: 13.5);
  }

  static const double tabIndicatorBorderWidth = 3.0;
//enddialog

//start tournament snackbars
  static const double tournamentSnackbarleftPadding = 10;
  static const double tournamentSnackbartopPadding = 5;
//end tournament snackbar

//Dark theme
  static const double darkThemeTextFieldHeight = 40;

//textfield radius
  static const double darkThemeTextRadius = 8;
  static const double darkThemeSmallButtonRadius = 5;

  //Divider margin inside textfield
  static const double darkThemeDividerMargin = 9;

//bottom nav top radius
  static const double darkThemeBottomNavTopRadius = 20;
  static const double darkThemeBottomNavHeight = 60;

//pot card spacing
  static const double darkThemePurpleCardPadding = 10;
  static const double darkThemePurpleCardHeight = 23;
  static const double darkThemeMainCardPadding = 10;

}

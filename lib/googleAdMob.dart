import 'package:flutter/material.dart';
// 비동기 작업의 완료 상태 확인을 위함
import 'dart:async';
// 구글 애드몹 사용을 위함
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdMob {
  // 배너 광고 인스턴스를 생성하고 로딩하기 위한 함수
  static BannerAd loadBannerAd() {
    // 배너 광고
    BannerAd myBanner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 내 리워드 광고 통합 APP ID
      /*
      크기(폭x높이)        설명               AdSize 상수
      -----------------------------------------------------------------------
      320x50	            표준 배너	          banner
      320x100	            대형 배너	          largeBanner
      320x250	            중간 직사각형	      mediumRectangle
      468x60	            전체 크기 배너	    fullBanner
      728x90	            리더보드	          leaderboard
      화면 폭x32|50|90	  스마트 배너	        getSmartBanner(Orientation) 사용
      */
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        // 광고가 성공적으로 수신된 경우
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // 광고 요청이 실패한 경우
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // 광고 요청 오류 시 광고를 삭제하여 리소스 확보
          ad.dispose();
          print('Ad failed to load: $error');
        },
        // 광고가 화면을 덮는 오버레이를 열었을 때 호출
        // 사용자가 광고를 클릭하거나 특정 조건이 충족되어 광고가 표시 될 때 발생
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // 광고가 화면을 덮는 오버레이를 닫았을 때 호출
        // 사용자가 광고를 닫거나 자동으로 닫힐 때 발생
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // 광고가 노출 될 때 호출
        // 광고가 사용자에게 보여질 때 발생
        onAdImpression: (Ad ad) => print('Ad impression.'),
      ),
    );
    return myBanner;
  }

  // 배너 광고를 화면에 보여주기 위한 함수, 파라미터로 로드된 배너 인스턴스 필요
  static Container showBannerAd(BannerAd myBanner) {
    // 광고 디스플레이
    // 배너 광고를 위젯으로 표시하기 위해 지원되는 광고를 사용하여 AdWidget 인스턴스화
    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: AdWidget(ad: myBanner),
    );

    return adContainer;
  }
}

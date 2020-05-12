# cordova-plugin-iamport-kcp(DEPRECATED)
해당 프로젝트는 아이오닉 상위 버전과 호환 및 외부 라이브러리 의존도를 해결하기 위해 [iamport-cordova](https://github.com/iamport/iamport-cordova) 플러그인으로 대체되어 DEPRECATED 되었습니다. `iamport-cordova` 플러그인으로 코르도바 프로젝트, 아이오닉 - 앵귤러 프로젝트에서 아임포트 일반/정기결제 및 본인인증 기능을 이용하실 수 있습니다. 아이오닉 - 리액트 프로젝트는 [iamport-capacitor](https://github.com/iamport/iamport-capacitor) 플러그인을 사용하시면 됩니다. 자세한 내용은 아래 매뉴얼을 참고해주세요.

- [코르도바 프로젝트에서 아임포트 연동하기](https://github.com/iamport/iamport-cordova/blob/master/README.md)
- [아이오닉 - 앵귤러 프로젝트에서 아임포트 연동하기](https://github.com/iamport/iamport-cordova/blob/master/manuals/IONIC.md)
- [아이오닉 - 리액트 프로젝트/캐패시터 프로젝트에서 아임포트 연동하기](https://github.com/iamport/iamport-capacitor/blob/master/README.md)

____________________________________________________________________

[아임포트](http://www.iamport.kr) KCP결제 및 휴대폰 본인인증을 cordova 환경에서 연동하기 위한 플러그인입니다.

## 준비 사항  
결제테스트까지 수행하기 위해서는 [아임포트 관리자 페이지](https://admin.iamport.kr) 에서 계정 생성이 필요합니다.  
계정 생성 후 시스템 설정 > 내정보에서 발급된 `가맹점식별코드` 확인이 필요합니다.  

## 설치  

이 플러그인은 아임포트 연동에 맞게 커스터마이즈된 [inappbrowser(fork 버전)](https://github.com/iamport/cordova-plugin-inappbrowser) 플러그인을 의존합니다.  

아래 명령어에 기재된 `cordovakcp`는 실제 사용을 원하는 scheme 값으로 대체하여 설치하면 됩니다.(개발 중인 앱을 대표할 수 있는 문자열로 다른앱과 겹치지 않게 고유한 값을 사용해주세요)  

```bash
cordova plugin add cordova-plugin-iamport-kcp --variable URL_SCHEME=cordovakcp --save
```

플러그인 설치가 되면 javascript module이 자동 복사/등록됩니다.(cordova-iamport.js)  

결제가 필요한 순간에 다음과 같이 javascript 호출을 통해 `inappbrowser`를 통해 결제 프로세스를 시작할 수 있습니다.  

```javascript
CordovaIamport.payment(user_code, param, callback)
```

휴대폰 본인인증은 다음의 javascript 호출을 통해 가능합니다.     

```javascript
CordovaIamport.certification(user_code, param, callback)
```

### 1. 특징  
cordova 특성상 `inappbrowser`를 통해 결제프로세스가 진행되므로 모바일 브라우저 연동과는 다소 차이가 있습니다. 
`m_redirect_url`속성을 overwrite하여 `inappbrowser`결제를 구현하고 있기 때문에 다음과 같은 차이점이 있습니다.  
(참조 : [cordova-iamport.js](https://github.com/iamport/iamport-ionic-inicis/blob/master/www/js/cordova-iamport.js#L18-L19))  

- m\_redirect\_url속성을 선언할 필요가 없음(선언해도 overwrite됨)  
- callback에 전달되는 rsp속성이 제한됨(success, imp\_uid, merchant\_uid, error\_msg 뿐)  

### 2. 결제연동 Example  
```javascript
CordovaIamport.payment('imp33886024', {
    pay_method : 'card',
    merchant_uid : 'merchant_' + new Date().getTime(),
    name : '주문명:결제테스트',
    amount : 1400,
    buyer_email : 'iamport@siot.do',
    buyer_name : '구매자이름',
    buyer_tel : '010-1234-5678',
    buyer_addr : '서울특별시 강남구 삼성동',
    buyer_postcode : '123-456'
}, function(rsp) {
    if ( rsp.success ) {
        var msg = '결제가 완료되었습니다.';
        msg += '고유ID : ' + rsp.imp_uid;
        msg += '상점 거래ID : ' + rsp.merchant_uid;
    } else {
        var msg = '결제에 실패하였습니다.';
        msg += '에러내용 : ' + rsp.error_msg;
    }
    alert(msg);
});
```

### 3. 본인인증 Example  
```javascript
CordovaIamport.payment('가맹점식별코드', {
    name : '홍길동'
}, function(rsp) {
    if ( rsp.success ) {
        var msg = '본인인증이 완료되었습니다.';
        msg += '고유ID : ' + rsp.imp_uid;
    } else {
        var msg = '본인인증에 실패하였습니다.';
        msg += '에러내용 : ' + rsp.error_msg;
    }
    alert(msg);
});
```

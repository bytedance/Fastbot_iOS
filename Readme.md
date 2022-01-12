## Introduction
Fastbot is a model-based testing tool for modeling GUI transitions to discover app stability problems. It combines machine learning and reinforcement learning techniques to assist discovery in a more intelligent way.
> Related: [Fastbot_Android](https://github.com/bytedance/Fastbot_Android)
 
***More detail see at [Fastbot architecture](https://mp.weixin.qq.com/s/QhzqBFZygkIS6C69__smyQ)

**update 2022.1**
* update Fastbot Revised License
* release AnyTrace, the Fastbot test management assistant: supports one-click Fastbot test start, crash analysis, etc. ([AnyTrace User Manual](https://volcengine.bytedance.net/docs/6431/82895))


## Prepare test environment
  * `cd Fastbot-iOS && pod install --repo-update`
  * Open `Fastbot-iOS.xcworkspace`, Set `FastbotRunner` [Signing & Capabilities](./Doc/Fastbot-Xcode-Sign.png) and [Bundle ID](./Doc/Fastbot-Xcode-BundleId.png)
  * USB connected the device & trust the device, if you're using a simulator, start up the simulator
  * Open FastbotRunner network permission (unnecessary for simulator), a sample on device 00008030-001054A80C82802E：
  *   - Open [XcodeIDE run `testPingNetwork` in Tests](./Doc/Fastbot-Xcode-IDE.png) or Run command:
```shell
BUNDLEID=com.apple.Pages duration=240 throttle=300 xcodebuild test  -workspace Fastbot-iOS.xcworkspace -scheme FastbotRunner  -configuration Release  -destination 'platform=iOS,id=00008030-001804563E44802E' -only-testing:FastbotRunner/FastbotRunner/testPingNetwork
```
  *   - By tapping FastbotRunner on the device, the screen of the device would go black for about one minute. During the black screen interval, users should press the home button on the device to go back to the main screen. Wait patiently until the network setting dialog window pops up. Users should allow the pop up request in order to continue.
  *   - If "`ping network success`" appears in the console log, that means get network permission **successful**

## Run Test
  * Ensure that your application can run on the device. (Installed and trusted)
  * Environment Variables should be setted in command line or [Xcode IDE/Scheme/Test](./Doc/Fastbot-Xcode-Scheme.png)

|key|note|sample|
|--|--|--|
| BUNDLEID| Test App's Bundle ID|com.apple.Pages
|duration|Test duration,  units of minutes|300
|launchenv|Start arguments for Test APP, can be empty or key-values separated with ":" |isAutoTestUI=1:channel=AutoTest
|throttle|Throttle for operate, units of millisecond|300

 * A sample run test on device 00008030-001054A80C82802E. *if IDE scheme Env Vars changed , command Env Var would be void*: 
```shell
BUNDLEID=com.apple.Pages duration=240 throttle=300 xcodebuild test  -workspace Fastbot-iOS.xcworkspace -scheme FastbotRunner  -configuration Release  -destination 'platform=iOS,id=00008030-001804563E44802E' -only-testing:FastbotRunner/FastbotRunner/testFastbot
```

***More detail see at [中文手册](./Doc/handbook-cn.md)***


-----------
## Advanced Extension
Stub mode: Target dynamic library [`fastbot_stub`](./Fastbot-iOS/fastbot-stub/stub.m). Stub mode requires injection of fastbot_stub into the test app. The library captures GUI structure by parsing the app under test for fastbot. More customized features (eg. hook callback, cut View) can be constructed by users for additional abilities such as blocking certain view from being clicked, customized ViewControllers, etc.

*We highly appreciate any contribution from the community !!!*

**Usage**: 
After injecting fastbot_stub to app, you need：
* Uncomment code block `[fastbot_native addUIInterruptionMonitor: ...];`  in [FastbotRunner.m](./Fastbot-iOS/FastbotRunner/FastbotRunner.m#L57)
* Run the stub mode by editing [Scheme Environment Variables](./Doc/Fastbot-Xcode-Scheme.png)(9797 can be changed to another port number):

|key|sample|
|--|--|
|launchenv|stubPort=9797
|dataport|9797

-----------
## Analytics

To prioritize and improve Fastbot-iOS, FastbotRunner collects usage data and uploads it to Google Analytics. FastbotRunner collects the md5 hash of the test app's Bundle ID, this information allows us to measure the volume of usage. If they wish, users can choose to disable the Analytics by skip step `Open FastbotRunner network permission` or change FastbotRunner's `Wireless Data` to off in System Preference.

-----------
## Support
* Public technical discussion on github is preferred.
* Q&A:

    **Q**: Get Error when `pod install --repo-update`<br>
    **A**: install pod firstly `sudo gem install cocoapods -v=1.8.1`
    <br>

    **Q**: Get Error: `Assert Fail Timed out while evaluating UI query`<br>
        **A**:  Restart test or Replug USB or Change a USB line or Restart iPhone
    <br>

    **Q**: Get Error when use simulator<br>
          **A**: Change to Debug Mode in scheme setting
    <br>


    **Q**: Get unkown install Error:`com.apple.dt.MobileDeviceErrorDomain` <br>
          **A**: Check your signing certificate or Replug USB or Change a USB line or Restart iPhone  
    <br>

--------
## License
>  Copyright©2021 Bytedance
>
>  Licensed under [MIT](./LICENSE) 

Fastbot-iOS required some features are based on or derives from projects below:
* [WebDriverAgent](https://github.com/facebook/WebDriverAgent) licensed under BSD-3-Clause



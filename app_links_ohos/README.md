# app_links_ohos
This plugin supports using deep links on HarmonyOS.

This plugin is based on version [oh-3.22.3](https://gitee.com/harmonycommando_flutter/flutter/tree/oh-3.22.3/)

## Getting Started
```yarml
app_links_ohos: ^1.0.0
```

[Deep link Tool Documentation](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V13/deep-linking-startup-V13)


## Test
About testing Ohos Deep Link:

You can use the Harmony-provided aa tool for testing.

Specific steps are as follows:
[aa Tool Documentation](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V13/aa-tool-V13)

 ```shell
 hdc shell aa start -U myscheme://www.test.com:8080/path
 ```
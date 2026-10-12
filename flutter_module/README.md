# Flutter Module 接入层

这个目录由 `flutter create --template=module` 创建，通过 `pubspec.yaml` 中
`my_app_douyin: { path: .. }` 依赖上一级 Flutter 工程。
`lib/main.dart` 调用现有工程的 `main()`，因此修改根目录 `lib/` 就会更新原生宿主中的页面。

执行 `flutter pub get` 会生成 `.android/include_flutter.groovy` 和 Android library。
这些是 Flutter 工具生成的文件，请勿手动修改或提交 `.android/`。
原生代码和 Manifest 配置写在 `../native_android/`。

完整构建和调试步骤见 [项目说明](../README.md)。

import { NativeModules } from "react-native";

export const ShareMenuReactView = {
  dismissExtension(error = null) {
    NativeModules.ShareMenuReactView.dismissExtension(error);
  },
  openApp() {
    NativeModules.ShareMenuReactView.openApp();
  },
  data() {
    return NativeModules.ShareMenuReactView.data();
  },
};

# Prerequisites

You need Lein and CocoaPods and Xcode.

# Usage

1. In the `ClojureScript` directory run `lein cljsbuild once dev`.
2. In the `iOS` directory run `pod install`.
3. Open `Bocko.xcworkspace` and run the Bocko app in a simulator or on a device.
4. In the `ClojureScript` directory run `script/repl`.
5. Choose your discovered Bocko app.
6. In the REPL, `(require '[bocko.core :refer [color plot scrn hlin vlin clear *color*]])`.

Now you can use Bocko, plotting in your simulator or on your device.

```
cljs.user=> (color :pink)
nil
cljs.user=> (plot 3 4)
nil
```


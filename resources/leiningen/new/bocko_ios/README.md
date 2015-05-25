# Prerequisites

You need Lein and CocoaPods and Xcode.

# Usage

1. In the `ClojureScript` directory run `lein cljsbuild once dev`.
2. In the `iOS` directory run `pod install`.
3. Open `Bocko.xcworkspace` and run the Bocko app in a simulator or on a device.
4. In the `ClojureScript` directory run `script/repl`.
5. Choose your discovered Bocko app.
6. In the REPL, `(require '[bocko.core :refer [color plot scrn hlin vlin clear *color*]])`.

Now you can plot:
```clojure
(plot 2 3)      ;; plots a point on the screen

(color :pink)   ;; changes the color to pink
(plot 5 5)

(scrn 5 5)      ;; => :pink

(hlin 3 9 10)   ;; draws a horizontal line

(clear)         ;; clears screen
```

The commands comprise `color`, `plot`, `scrn`, `hlin`, `vlin`, and `clear`.

To get the documentation for a command, type, for example, `(doc color)` in the REPL.

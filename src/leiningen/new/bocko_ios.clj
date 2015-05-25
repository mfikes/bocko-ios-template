(ns leiningen.new.bocko-ios
  (:require [leiningen.new.templates :refer [renderer name-to-path ->files]]
    [leiningen.core.main :as main])
  (:use [clojure.java.io :as io]
    [leiningen.new.templates :only [renderer sanitize year ->files]]))

(def ^{:private true :const true} template-name "bocko-ios")

(def render-text (renderer template-name))

(defn resource-input
  "Get resource input stream. Useful for binary resources like images."
  [resource-path]
  (-> (str "leiningen/new/" (sanitize template-name) "/" resource-path)
    io/resource
    io/input-stream))

(defn render
  "Render the content of a resource"
  ([resource-path]
    (resource-input resource-path))
  ([resource-path data]
    (render-text resource-path data)))

(defn bocko-ios
  "FIXME: write documentation"
  [name]
  (let [data {:name      name
              :sanitized (name-to-path name)}]
    (main/info "Generating fresh 'lein new' bocko-ios project.")
    (->files data
      ["README.md" (render "README.md" data)]
      ["ClojureScript/project.clj" (render "project.clj" data)]
      ["ClojureScript/externs.js" (render "externs.js" data)]
      ["ClojureScript/script/repl" (render "repl" data) :executable true]
      ["ClojureScript/src/bocko_ios/core.cljs" (render "core.cljs" data)]
      ["iOS/Podfile" (render "Podfile")]
      ["iOS/Bocko.xcodeproj/project.pbxproj" (render "project.pbxproj")]
      ["iOS/Bocko.xcodeproj/project.xcworkspace/contents.xcworkspacedata" (render "contents.xcworkspacedata")]
      ["iOS/Bocko/Base.lproj/LaunchScreen.xib" (render "LaunchScreen.xib")]
      ["iOS/Bocko/Base.lproj/Main.storyboard" (render "Main.storyboard")]
      ["iOS/Bocko/Images.xcassets/AppIcon.appiconset/Contents.json" (render "Contents.json")]
      ["iOS/Bocko/Images.xcassets/AppIcon.appiconset/icon-120-1.png" (render "icon-120-1.png")]
      ["iOS/Bocko/Images.xcassets/AppIcon.appiconset/icon-120.png" (render "icon-120.png")]
      ["iOS/Bocko/Images.xcassets/AppIcon.appiconset/icon-180.png" (render "icon-180.png")]
      ["iOS/Bocko/Images.xcassets/AppIcon.appiconset/icon-58.png" (render "icon-58.png")]
      ["iOS/Bocko/Images.xcassets/AppIcon.appiconset/icon-80.png" (render "icon-80.png")]
      ["iOS/Bocko/Images.xcassets/AppIcon.appiconset/icon-87.png" (render "icon-87.png")]
      ["iOS/Bocko/AppDelegate.h" (render "AppDelegate.h")]
      ["iOS/Bocko/AppDelegate.m" (render "AppDelegate.m")]
      ["iOS/Bocko/CanvasView.h" (render "CanvasView.h")]
      ["iOS/Bocko/CanvasView.m" (render "CanvasView.m")]
      ["iOS/Bocko/Info.plist" (render "Info.plist")]
      ["iOS/Bocko/ViewController.h" (render "ViewController.h")]
      ["iOS/Bocko/ViewController.m" (render "ViewController.m")]
      ["iOS/Bocko/main.m" (render "main.m")])))

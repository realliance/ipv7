(ns user-front.core
  (:require
   [reagent.core :as reagent :refer [atom]]
   [reagent.dom :as rdom]
   [reagent.session :as session]
   [reitit.frontend :as reitit]
   [clerk.core :as clerk]
   [clojure.core.match :as m]
   [accountant.core :as accountant]))

;; -------------------------
;; Routes

(def routes
  [["/" :index]
    ["/register" :register]
    ["/login" :login]
    ["/profile" :profile]])

(defn get-routes [logged-in]
  (m/match [logged-in]
  [false]
    [["/" "Home"]
      ["/register" "Register"]
      ["/login" "Login"]]
  [true]
    [["/" "Home"]
      ["/profile" "Profile"]]
  )
)

(def router
  (reitit/router routes))

(defn path-for [route & [params]]
  (if params
    (:path (reitit/match-by-name router route params))
    (:path (reitit/match-by-name router route))))

(defn get-route-element [tup]
  (let [[path name] tup]
  [:a.navbar-item {:href path} name]))

(defn get-route-elements [r]
  (map (fn [tup] (get-route-element tup)) r))

;; -------------------------
;; Page components

(defn home-page []
  (fn []
    [:span.main
     [:h1 "Home"]]))

(defn register-page []
  (fn [] [:span.main
          [:h1 "About user-front"]]))

(defn login-page []
  (fn [] [:span.main
          [:h1 "About user-front"]]))

(defn profile-page []
  (fn [] [:span.main
          [:h1 "About user-front"]]))

;; -------------------------
;; Translate routes -> page components

(defn page-for [route]
  (case route
    :index #'home-page
    :register #'register-page
    :login #'login-page
    :profile #'profile-page))


;; -------------------------
;; Page mounting component

(defn current-page []
  (fn []
    (let [page (:current-page (session/get :route))
          logged-in (:logged-in (session/get :user))
          route-elements (get-route-elements (get-routes logged-in))]
      [:div
        [:header
          [:h1 "IPv8"]
          (conj [:p.navbar] route-elements)
        ]
        [page]
      ])))

;; -------------------------
;; Initialize app

(defn mount-root []
  (rdom/render [current-page] (.getElementById js/document "app")))

(defn init! []
  (clerk/initialize!)
  (accountant/configure-navigation!
   {:nav-handler
    (fn [path]
      (let [match (reitit/match-by-path router path)
            current-page (:name (:data  match))
            route-params (:path-params match)]
        (reagent/after-render clerk/after-render!)
        (session/put! :route {:current-page (page-for current-page)
                              :route-params route-params})
        (session/put! :user {:logged-in false})
        (clerk/navigate-page! path)
        ))
    :path-exists?
    (fn [path]
      (boolean (reitit/match-by-path router path)))})
  (accountant/dispatch-current!)
  (mount-root))

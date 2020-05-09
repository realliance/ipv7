(ns user-front.core
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require
   [reagent.core :as reagent :refer [atom]]
   [reagent.dom :as rdom]
   [reagent.session :as session]
   [reitit.frontend :as reitit]
   [clerk.core :as clerk]
   [clojure.core.match :as m]
   [cljs-http.client :as http]
   [cljs.core.async :refer [<!]]
   [promesa.core :as p]
   [accountant.core :as accountant]))

;; -------------------------
;; Macros

(defmacro await-> [thenable & thens]
     `(-> ~thenable
          ~@thens
          ~'js/Promise.resolve
          p/await))

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
  [:a.col.3 {:href path} name]))

(defn get-route-elements [r]
  (map (fn [tup] (get-route-element tup)) r))

;; Request Functions




(defn send-register [name email password repeat-password state]
  (go (let [response (<! (http/post "http://localhost:4000/register"
                                 {:json-params {:name @name :email @email :password @password}}))]
      (reset! state (m/match [(:status response)]
        [200]
          :ok
        [400]
          :error
        )
      )
    )
  )
)


;; -------------------------
;; Util Components

(defn input-field [name type value]
  [:div
    [:label name]
    [:input.card.w-100 {:type type
             :value @value
             :on-change #(reset! value (-> % .-target .-value))}]
  ])

;; -------------------------
;; Page components

(defn home-page []
  (fn []
    [:span.main
     [:h1 "Home"]]))

(defn register-page []
  (let [name (atom "")
        email (atom "")
        password (atom "")
        repeat-password (atom "")
        submit-status (atom :none)]
    (fn [] [:span.main
            [:h2 "Register"]
            [:p @submit-status]
            [:form
              [input-field "Name" "text" name]
              [input-field "Email" "text" email]
              [input-field "Password" "password" password]
              [input-field "Repeat Password" "password" repeat-password]
              [:input.btn.primary {:type "button" :value "Submit"
                :on-click #(send-register name email password repeat-password submit-status)}]
            ]
          ])))

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
      [:div.c
        [:div.row
          [:h4.col "IPv8"]
          (conj [:p.col] route-elements)
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

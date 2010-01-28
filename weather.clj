; Attempt to fetch the weather from Wunderground.com
;
;<?xml version="1.0"?>
;<forecast>
;  <txt_forecast>
;    <date>3:45 AM CST</date>
;    <number>2</number>
;    <forecastday>
;      <period>1</period>
;      <icon>partlycloudy</icon>
;      <title>Today</title>
;      <fcttext>Partly cloudy in the morning becoming mostly sunny. Scattered flurries in the morning. Highs in the upper 20s. Lowest wind chill readings 1 below to 9 above zero in the morning. West winds 10 to 15 mph.</fcttext>
;    </forecastday>
;    <forecastday>
;      <period>2</period>
;      <icon>nt_sunny</icon>
;      <title>Tonight</title>
;      <fcttext>Mostly clear. Lows 16 to 20...except in the lower 20s downtown. Light and variable winds in the evening becoming south around 10 mph after midnight. </fcttext>
;    </forecastday>
;  </txt_forecast>
;... many other things ...
;</forecast>

(ns wunderground
  (:use [clojure.contrib.zip-filter.xml]
        [clojure.contrib.duck-streams])
  (:require [clojure.zip :as zip]
            [clojure.xml :as xml]))

(def *api* "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=")

(defn get-forecast
  [zipcode]
  (let [url (str *api* zipcode)
        feed (zip/xml-zip (xml/parse url))]
    (xml-> feed :txt_forecast :forecastday :fcttext text)))

(defn get-now-forecast
  [zipcode]
  (first (get-forecast zipcode)))

(defn get-later-forecast
  [zipcode]
  (second (get-forecast zipcode)))

(get-forecast "80602")

(get-now-forecast "80602")
(get-later-forecast "80602")


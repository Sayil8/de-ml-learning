CREATE TABLE taxirides.taxi_training_data_589 AS
SELECT pickup_datetime,
       pickup_latitude                                                as pickuplat,
       pickup_longitude                                               as pickuplon,
       dropoff_latitude                                               as dropofflat,
       dropoff_longitude                                              as dropofflon,
       passenger_count                                                as passangers,
       ST_Distance(ST_GeogPoint(pickup_longitude, pickup_latitude),
                   ST_GeogPoint(dropoff_longitude, dropoff_latitude)) AS trip_distance,
       (tolls_amount + fare_amount)                                   AS fare_amount_529
FROM `taxirides.historical_taxi_rides_raw`
WHERE trip_distance > 3
  AND fare_amount >= 2
  AND passenger_count > 3
  AND ABS(pickup_longitude) <= 90
  AND pickup_longitude != 0 AND
      ABS(pickup_latitude) <= 90 AND pickup_latitude != 0 AND
      ABS(dropoff_longitude) <= 90 AND dropoff_longitude != 0 AND
      ABS(dropoff_latitude) <= 90 AND dropoff_latitude != 0
  AND RAND() < 999999 / 1031673361

CREATE
or REPLACE MODEL
  taxirides.fare_model_798 OPTIONS (model_type='linear_reg',
    labels=['fare_amount_529']) AS
WITH
  taxitrips AS (
SELECT
   *,
   trip_distance as euclidean
  FROM
    `taxirides.taxi_training_data_589` )
SELECT *
FROM taxitrips



SELECT *
FROM
    ML.PREDICT(MODEL `taxirides.fare_model_789`,
               (WITH taxitrips AS (SELECT *,
                                          ST_Distance(ST_GeogPoint(pickuplon, pickuplat),
                                                      ST_GeogPoint(dropofflon, dropofflat)) AS euclidean
                                   FROM `taxirides.report_prediction_data`)
                SELECT *
                FROM taxitrips))

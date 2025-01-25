SELECT
  COUNT(*)
FROM
  `green-calling-444717-c7.trips_data_kestra.yellow_tripdata`
WHERE
  REGEXP_EXTRACT(filename, r".+_tripdata_([0-9]{4})-[0-9]{2}.csv.gz") = '2020'
